Minikube uses VMs to simulate nodes, and runs a full K8s, not a light version.
For a local devel(work) environment you can use KinD (Kubernetes in Docker - or
now Podman), which instead of VMs, will create a container that simulates each
node. If you need a K8s distribution that uses even less resources but provides
the same interface, you can try k3s.



## Running Kubernetes in Podman (KinD)
KinD has support for podman rootless too, so we don't even need to run a docker
daemon for it. but this is a larger K8s distribution, just like minikube, it
will install the full version of Kubernetes, thus using more resources than K3d.

Cluster config:
```yaml
# $(pwd)/config.yaml
---
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
#  apiServerAddress: 0.0.0.0
  apiServerAddress: 127.0.0.1
  apiServerPort: 6443
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30000
    hostPort: 30000
    listenAddress: "0.0.0.0" # Optional, defaults to "0.0.0.0"
    protocol: tcp # Optional, defaults to tcp
  - containerPort: 30001
    hostPort: 30001
    listenAddress: "0.0.0.0" # Optional, defaults to "0.0.0.0"
    protocol: tcp # Optional, defaults to tcp
  - containerPort: 30002
    hostPort: 30002
    listenAddress: "0.0.0.0" # Optional, defaults to "0.0.0.0"
    protocol: tcp # Optional, defaults to tcp
- role: worker
# - role: worker
# - role: worker
```
```sh
# Download binary file from GitHub:
# https://github.com/kubernetes-sigs/kind/releases
# Or from k8s.io:
paul@server $ wget https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64 -o ./kind
paul@server $ KIND_EXPERIMENTAL_PROVIDER=podman ./kind create cluster --name=local-devel --config=$(pwd)/config.yaml
using podman due to KIND_EXPERIMENTAL_PROVIDER
enabling experimental podman provider
Creating cluster "local-devel" ...
 ✓ Ensuring node image (kindest/node:v1.30.0) 🖼
 ✓ Preparing nodes 📦 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
 ✓ Joining worker nodes 🚜
Set kubectl context to "kind-local-devel"
You can now use your cluster with:

kubectl cluster-info --context kind-local-devel

Thanks for using kind! 😊

# The kubeconfig file is automatically placed in the default path:~/.kube/config
$ kubectl get nodes
NAME                        STATUS   ROLES           AGE     VERSION
local-devel-control-plane   Ready    control-plane   2m59s   v1.30.0
local-devel-worker          Ready    <none>          2m35s   v1.30.0
# Get cluster:
paul@server $ KIND_EXPERIMENTAL_PROVIDER=podman latest/kind get clusters
# Delete cluster:
paul@server $ KIND_EXPERIMENTAL_PROVIDER=podman latest/kind delete cluster --name=local-devel

# Will download a container image of ~1GiB:
paul@server $ podman images | grep kind
docker.io/kindest/node                                                 <none>                    9319cf209ac5  13 months ago  980 MB
```



## Running k3s

```sh
# Download the binary
wget https://github.com/k3s-io/k3s/releases/download/v1.33.1%2Bk3s1/k3s &&

# Start cluster (as a limited/rootless user)
systemd-run --user --property=Delegate=yes --pty --same-dir --wait --collect --service-type=exec ./k3s server --rootless
# Get kubeconfig access file from:
cat ${HOME}/.kube/k3s.yaml

# ===

# If running as a limited user does not work for some reason, you can run as
# root using:
# Remove any previous cluster info from disk:
sudo rm -rf \
  /etc/rancher/k3s \
  /var/lib/rancher/k3s \
  /var/lib/kubelet \
  /var/lib/containerd \
  /var/lib/cni \
  /run/k3s \
  &&
# Start cluster (as root), you should enable run it on your limited user.
sudo ./k3s server
# Get the kubeconfig access file from
sudo cat /etc/rancher/k3s/k3s.yaml

```
This is fine, the binary is self contained, but it only simulates one node, with
the name of your host. If you want to simulate multiple nodes, you can use k3d,
which will run one docker container for each node it simulates.

Since I don't want to expose access to my podman through a socket file, that k3d
needs, I will create an isolated docker daemon(in a podman container) and give
that to K3d.

### Running docker in podman
This needs you to have installed podman (will run as a limited/rootless user),
and the [docker client](
  https://download.docker.com/linux/static/stable/x86_64/docker-20.10.9.tgz).
The podman container will run the docker server inside, and expose it over TCP
to allow the docker client to use the service.
```sh
podman run \
  -d \
  --replace \
  --rm=true \
  --privileged \
  -p 2375:2375/tcp \
  -p 6444:6444/tcp \
  -e DOCKER_TLS_CERTDIR="" \
  --name docker_in_podman \
  docker.io/docker:28.3.0-dind-alpine3.22 \
  &&
# podman logs -f docker_in_podman
export DOCKER_HOST="tcp://127.0.0.1:2375" &&
docker ps -a
```
This allows you to run kind (Kubernetes in Docker) or k3d, or similar tools,
that require docker, even if you use podman.

### Creating a k3d cluster
```sh
# Get binary
wget -o ./k3d \
  https://github.com/k3d-io/k3d/releases/download/v5.8.3/k3d-linux-amd64 &&

# Create cluster named "dev-cluster" with 1 control plane and 2 workers
# ensure you've exported DOCKER_HOST from above
./k3d cluster create dev-cluster --servers 1 --agents 2 --api-port 0.0.0.0:6444 &&
```
```sh
# Will download ~310MiB of docker images:
$ docker images
REPOSITORY                 TAG            IMAGE ID       CREATED        SIZE
ghcr.io/k3d-io/k3d-proxy   5.8.3          49c793b9faf6   4 months ago   63.1MB
ghcr.io/k3d-io/k3d-tools   5.8.3          8622faa0d552   4 months ago   20.7MB
rancher/k3s                v1.31.5-k3s1   efe65d76faac   5 months ago   222MB
```

