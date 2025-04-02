# Following: https://www.digitalocean.com/community/tutorials/how-to-create-a-kubernetes-cluster-using-kubeadm-on-ubuntu-18-04

# Install ubuntu server 18.04.3
# Allow ssh root logins on k8s: sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && service ssh restart
# Change root pwd: passwd
# Copy key on k8s
# Tunnel k8s ssh connection to docker gw
ssh ci1 -N -L 172.17.0.1:10022:192.168.122.182:22

# Disable swap on workstation: swapoff -a ; sed -i 's/^\/swap.img/#&/' /etc/fstab
# If can not: kubeadm init - ports are used, then kill processes and try again. See https://github.com/kubernetes/kubeadm/issues/339

# ============================================================================ #
To install the dashboard run this on master:

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml

Then start listening on 127.0.0.1:8001 using:

kubectl proxy

You can use a tunnel to access the web interface.
In order to login using a token you can do this on master:
(thanks to: https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md )

  mkdir dashboard && cd dashboard &&

  ( cat - <<EOF >./dashboard-adminuser.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF
  ) &&
  kubectl apply -f ./dashboard-adminuser.yaml &&

  ( cat - <<EOF >./dashboard-ClusterRoleBinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
  ) &&
  kubectl apply -f dashboard-ClusterRoleBinding.yaml &&


Then this command will give you the token:
ubuntu@k8s-master:~$ kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

# This will help you monitor the cluster:
watch -n 1 -t -d "echo Nodes: ; kubectl get nodes ; echo;echo Pods: ; kubectl get pods ; echo;echo Deployments: ; kubectl get deployments ; echo;echo Services: ; kubectl get services ; echo;echo Volumes: ; kubectl get pv"

list pods: kubectl get pods
CLI to pod: kubectl exec -it pod_name -- /bin/bash

Allow master to run pods: kubectl taint nodes --all node-role.kubernetes.io/master-

# ============================================================================ #

1. Nodes:
  1.1. list: kubectl get nodes
  1.2. create: kubeadm join ... # on the worker
    Get actual allocated port from list of services
  1.3. delete: kubectl drain node_name --ignore-daemonsets

2. Deployments:
  2.1. list: kubectl get deployments
  2.2. create: kubectl create deployment prometheus --image=prom/prometheus:v2.14.0
    Get actual allocated port from list of services
  2.3. delete: kubectl delete deployment prometheus

3. Services:
  3.1. list: kubectl get services
  3.2. create: kubectl expose deploy prometheus --port 9090 --target-port 9090 --type NodePort
    Get actual allocated port from list of services
  3.3. delete: kubectl delete service prometheus

4. Volumes:
  4.1. list: kubectl get pv
  4.2. delete: kubectl delete pv volume_name

# ============================================================================ #
