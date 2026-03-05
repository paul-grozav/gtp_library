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
    server: https://192.168.0.71:8232
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

Some of these certificate files are stored in `/etc/kubernetes/pki/`.
| Certificate              | Certificate file                              | Key file                          |
| ------------------------ | --------------------------------------------- | --------------------------------- |
| admin.conf               |                                               |                                   |
| apiserver                | /etc/kubernetes/pki/apiserver.crt             | /etc/kubernetes/pki/apiserver.key |
| apiserver-etcd-client    | /etc/kubernetes/pki/apiserver-etcd-client.crt |                                   |
| apiserver-kubelet-client |                                               |                                   |
| controller-manager.conf  |                                               |                                   |
| etcd-healthcheck-client  |                                               |                                   |
| etcd-peer                |                                               |                                   |
| etcd-server              |                                               |                                   |
| front-proxy-client       |                                               |                                   |
| scheduler.conf           |                                               |                                   |
| super-admin.conf         |                                               |                                   |
```

# kubeadm cert renewal

```sh
# kubeadm certs renew apiserver
# That will renew only the apiserver certificate which usually lives in
```

See also:
1. https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/
