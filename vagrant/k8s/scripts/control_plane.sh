#!/bin/bash
# ============================================================================ #
# Authors:
# - Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# Setup for Control Plane (Master) servers
# ============================================================================ #
set -euxo pipefail &&
env &&

echo "Downloading K8s images ..." &&
kubeadm config images pull &&

local_ip="$(ip --json a s | jq -r ".[] |
  if .ifname == \"eth1\"
  then
    .addr_info[] |
      if .family == \"inet\"
      then
        .local
      else
        empty
      end
  else
    empty
  end"
)" &&

echo "Initializing control plane node ..." &&
kubeadm init \
  --v 5 \
  --ignore-preflight-errors Swap \
  --upload-certs \
  ` # This points to the LoadBalancer that balances between the control ` \
  ` # plane IPs, on destination port 6443. This is where the other nodes` \
  ` # will connect when they join the cluster. ` \
  --control-plane-endpoint 192.168.0.12:6443 \
  --pod-network-cidr ${POD_CIDR} \
  --service-cidr ${SERVICE_CIDR} \
  ` # This is required because the VM has 2 interfaces, and by default ` \
  ` # kubeadm selects the one with the default route to the gateway.` \
  ` # In Vagrant's case, that is the "IPMI" control interface eth0 . We want ` \
  ` # To use the second interface: eth1 . This IP is where the other nodes ` \
  ` # that join the cluster, are going to connect to etcd for example(to ` \
  ` # join/form the etcd cluster). ` \
  --apiserver-advertise-address ${local_ip} \
  &&
  # --apiserver-cert-extra-sans 192.168.0.12 \
  #
  # --control-plane-endpoint ${CONTROL_IP}:6443 \
  # --node-name $(hostname -s) \
  # --image-repository registry.example.com/my_containers \

echo "Copying kubeconfig to root's home folder ..." &&
mkdir -p ${HOME}/.kube &&
cp -i /etc/kubernetes/admin.conf ${HOME}/.kube/config &&
chown $(id -u):$(id -g) -R ${HOME}/.kube &&

echo "Copying kubeconfig to vagrant's home folder ..." &&
mkdir -p /home/vagrant/.kube &&
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config &&
chown 1000:1000 -R /home/vagrant/.kube &&

echo "Saving Configs to shared Vagrant storage ..." &&
config_path=/vagrant/configs &&
mkdir -p ${config_path} &&
# For Vagrant re-runs, check if there is existing configs in the location and
# delete it for saving new configuration.
rm -f ${config_path}/* &&
cp -i /etc/kubernetes/admin.conf ${config_path}/config &&
(
  kubeadm token create --print-join-command &&
  echo -n " --v 5" &&
  true
) > ${config_path}/join_worker.sh &&
(
  echo -n "$(cat ${config_path}/join_worker.sh)" &&
  echo -n " --control-plane --certificate-key " &&
  kubeadm init phase upload-certs --upload-certs |
    grep -v "^\[upload-certs\] " &&
  true
) > ${config_path}/join_control_plane.sh &&

schedule=$(yq .nodes.control.schedule /vagrant/settings.yml) &&
if [ "${schedule}" == "true" ]
then
  ( kubectl taint nodes --all node-role.kubernetes.io/control-plane- ||
    true ) &&
  true
fi &&

echo "Installing Calico Network Plugin ..." &&
calico_url="https://raw.githubusercontent.com/projectcalico/calico" &&
calico_url="${calico_url}/v${CALICO_VERSION}/manifests/calico.yaml" &&
kubectl apply -f ${calico_url} &&

echo "Installing Metrics Server ..." &&
metrics_url="https://raw.githubusercontent.com/techiescamp/kubeadm-scripts" &&
metrics_url="${metrics_url}/main/manifests/metrics-server.yaml" &&
kubectl apply -f ${metrics_url} &&

bash /vagrant/scripts/common.sh --dashboard &&
bash /vagrant/scripts/common.sh --longhorn &&

echo "Done setting up the control plane node!" &&
exit 0
# ============================================================================ #
