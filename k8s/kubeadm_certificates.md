# kubeconfig structure
A Kubeconfig file has this structure:
```yaml
apiVersion: v1
kind: Config
preferences: {}
clusters:
- name: home-k8s
  cluster:
    certificate-authority-data: SECRET_DATA1
    server: https://192.168.0.71:6443
users:
- name: admin
  user:
    client-certificate-data: SECRET_DATA2
    client-key-data: SECRET_DATA3
contexts:
- name: admin@home-k8s
  context:
    cluster: home-k8s
    user: admin
current-context: admin@home-k8s
```


It contains a list of clusters, each one having a name and a pair of CA
(`certificate-authority-data`) and the KubeAPI server endpoint (`server`) (which
is usually a pool/load balancer between the multiple control-plane nodes - if
there are more than 1).

Also, the kubeconfig contains a list of users, with a name and a pair of
certificate (`client-certificate-data`) and private key (`client-key-data`).

Then, it contains a list of contexts, each having a name and connects a cluster
to a user.

Then you have a default/current context that is used by default when you use
that kubeconfig file.

Other parameters can be specified too - for the full API see:
https://kubernetes.io/docs/reference/config-api/kubeconfig.v1/

```sh
# Show the full certificate
yq -r '.clusters[0].cluster."certificate-authority-data"' /data/k8s/kubeconfig.yaml | base64 -d | openssl x509 -noout -text
yq -r '.users[0].user."client-certificate-data"' /data/k8s/kubeconfig.yaml | base64 -d | openssl x509 -noout -text
# Or just the validity period
yq -r '.clusters[0].cluster."certificate-authority-data"' /data/k8s/kubeconfig.yaml | base64 -d | openssl x509 -noout -dates
yq -r '.users[0].user."client-certificate-data"' /data/k8s/kubeconfig.yaml | base64 -d | openssl x509 -noout -dates
```

Note: `client-key-data` in the kubeconfig file is the Base64-encoded private key
associated with that client certificate. While it doesn't "expire" in the same
way as the certificates, it is useless without a valid, signed certificate to go
with it.




# kubeadm certificates
```sh
# kubeadm certs check-expiration
CERTIFICATE                EXPIRES                  RESIDUAL TIME   CERTIFICATE AUTHORITY   EXTERNALLY MANAGED
admin.conf                 Dec 30, 2020 23:36 UTC   364d            ca                      no
apiserver                  Dec 30, 2020 23:36 UTC   364d            ca                      no
apiserver-etcd-client      Dec 30, 2020 23:36 UTC   364d            etcd-ca                 no
apiserver-kubelet-client   Dec 30, 2020 23:36 UTC   364d            ca                      no
controller-manager.conf    Dec 30, 2020 23:36 UTC   364d            ca                      no
etcd-healthcheck-client    Dec 30, 2020 23:36 UTC   364d            etcd-ca                 no
etcd-peer                  Dec 30, 2020 23:36 UTC   364d            etcd-ca                 no
etcd-server                Dec 30, 2020 23:36 UTC   364d            etcd-ca                 no
front-proxy-client         Dec 30, 2020 23:36 UTC   364d            front-proxy-ca          no
scheduler.conf             Dec 30, 2020 23:36 UTC   364d            ca                      no

CERTIFICATE AUTHORITY   EXPIRES                  RESIDUAL TIME   EXTERNALLY MANAGED
ca                      Dec 28, 2029 23:36 UTC   9y              no
etcd-ca                 Dec 28, 2029 23:36 UTC   9y              no
front-proxy-ca          Dec 28, 2029 23:36 UTC   9y              no
```

You will see the output provides 2 sections. The first one lists the
certificates and the second one lists the certificates authorities. Each
certificate is signed by a certificate authority.

CAs (Certificate Auhtorities) appears in the kubeconfig file, in field:
`certificate-authority-data`. These are generated for 10 years, and can be
renewed beyond.

The certificates are used for client authentication. When they expire,
the `kubectl` will stop working. That is because all kubeconfig files have the
certificate inside of them (the `client-certificate-data` field). This usually
gets generated for 1 year, and then can be renewed. Each certificate is signed
using one of the CA listed above.

Location for the certificates and CAs:

Certificates
| Certificate              | Certificate file                                 | Private key file                                 |
| ------------------------ | ------------------------------------------------ | ------------------------------------------------ |
| apiserver                | /etc/kubernetes/pki/apiserver.crt                | /etc/kubernetes/pki/apiserver.key                |
| apiserver-etcd-client    | /etc/kubernetes/pki/apiserver-etcd-client.crt    | /etc/kubernetes/pki/apiserver-etcd-client.key    |
| apiserver-kubelet-client | /etc/kubernetes/pki/apiserver-kubelet-client.crt | /etc/kubernetes/pki/apiserver-kubelet-client.key |
| etcd-healthcheck-client  | /etc/kubernetes/pki/etcd/healthcheck-client.crt  | /etc/kubernetes/pki/etcd/healthcheck-client.key  |
| etcd-peer                | /etc/kubernetes/pki/etcd/peer.crt                | /etc/kubernetes/pki/etcd/peer.key                |
| etcd-server              | /etc/kubernetes/pki/etcd/server.crt              | /etc/kubernetes/pki/etcd/server.key              |
| front-proxy-client       | /etc/kubernetes/pki/front-proxy-client.crt       | /etc/kubernetes/pki/front-proxy-client.key       |


KubeConfig files with embedded certificates:
| Certificate              | Configuration file                               |
| ------------------------ | ------------------------------------------------ |
| admin.conf               | /etc/kubernetes/admin.conf                       |
| controller-manager.conf  | /etc/kubernetes/controller-manager.conf          |
| scheduler.conf           | /etc/kubernetes/scheduler.conf                   |
| super-admin.conf         | /etc/kubernetes/super-admin.conf                 |


Authorities:
| Certificate authority | Certificate file                       | Private key file                       |
| --------------------- | -------------------------------------- | -------------------------------------- |
| ca                    | /etc/kubernetes/pki/ca.crt             | /etc/kubernetes/pki/ca.key             |
| etcd-ca               | /etc/kubernetes/pki/etcd/ca.crt        | /etc/kubernetes/pki/etcd/ca.key        |
| front-proxy-ca        | /etc/kubernetes/pki/front-proxy-ca.crt | /etc/kubernetes/pki/front-proxy-ca.key |

The `admin.conf` is the Administrator (full privileges) account used with
`kubectl` to manage the cluster.

You can also use this command:
```sh
echo | openssl s_client -showcerts -connect 192.168.0.71:6443 -servername api 2>/dev/null | openssl x509 -noout -enddate
```
To connect to the KubeAPI server (where kubectl connects too), to get the server
certificate (`apiserver`) and verify it's end date.


# kubeadm cert renewal

```sh
# kubeadm certs renew apiserver
# # That will renew only the apiserver certificate ... or you could do:
# kubeadm certs renew all
...
Done renewing certificates. You must restart the kube-apiserver,
kube-controller-manager, kube-scheduler and etcd, so that they can use the new
certificates.


# To restart apiserver or others, use:
# sudo CONTAINER_RUNTIME_ENDPOINT=unix:///run/containerd/containerd.sock crictl pods
# you should see a pod kube-apiserver-master1 in namespace kube-system . You can
# delete that and kubelet will restart it automatically.
#
# Or simply: mv /etc/kubernetes/manifests/kube-apiserver.yaml /root
# It usually takes <30 seconds for the kubelet to find that the file is missing
# and it will stop the apiserver pod. Then moving the manifest file back, will
# make the kubelet start the apiserver pod again.
#
# You could use docker instead of crictl or whatever your runtime is, and you
# can also move all /etc/kubernetes/manifests/*.yaml at once to restart all
# pods.
```

See also:
1. https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/
