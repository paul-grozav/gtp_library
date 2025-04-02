#!/bin/bash
# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
exit 0 &&

# ============================================================================ #
# On CentOS 8 :
# ============================================================================ #
(
  set -x &&

  # So if you’re running Kubernetes version 1.19, you’ll install cri-o 1.19.x.
  KUBE_VERSION=1.19 &&

  # Install CRI-O
  OS=CentOS_8 &&
  dnf -y install 'dnf-command(copr)' &&
  dnf -y copr enable rhcontainerbot/container-selinux &&
  curl -L \
    -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo \
    https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/${OS}/devel:kubic:libcontainers:stable.repo &&
  curl -L \
    -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:${KUBE_VERSION}.repo \
    https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:${KUBE_VERSION}/${OS}/devel:kubic:libcontainers:stable:cri-o:${KUBE_VERSION}.repo &&
  dnf install -y cri-o &&
  systemctl enable --now cri-o &&

  ( cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
  ) &&

  # Set SELinux in permissive mode (effectively disabling it)
  sudo setenforce 0 &&
  sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config &&

  # Install K8s
  dnf install -y \
    kubelet-${KUBE_VERSION}* \
    kubeadm-${KUBE_VERSION}* \
    kubectl-${KUBE_VERSION}* \
    --disableexcludes=kubernetes &&
  systemctl enable --now kubelet &&

  # Turn off swap
  swapoff -a &&
  sed -e '/ swap / s/^#*/#/' -i /etc/fstab &&
  systemctl mask $(systemctl --type swap | grep "Swap Partition" | cut -d " " -f 1) &&

  # Enable ipv4 forward
  sysctl -w net.ipv4.ip_forward=1 &&
  ( [ "$(grep "net.ipv4.ip_forward = 1" /etc/sysctl.conf | wc -l)" == "0" ] && echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf || true ) &&

  # Load required kernel modules
  modprobe overlay &&
  modprobe br_netfilter &&
  echo "br_netfilter" >> /etc/modules-load.d/br_netfilter.conf &&
  dnf -y install iproute-tc &&

  # Configure kubelet to use cri-o
  (cat - <<EOF >/etc/sysconfig/kubelet
KUBELET_EXTRA_ARGS=--container-runtime=remote --cgroup-driver=systemd --container-runtime-endpoint="unix:///var/run/crio/crio.sock"
EOF
  ) &&

  # Initialize cluster - save join command
  ( [ ! -f ${HOME}/cluster_initialized.txt ] &&
    kubeadm init --pod-network-cidr=10.244.0.0/16 --v=99 \
      2>&1 | tee -a ${HOME}/cluster_initialized.txt \
    || true
  ) &&
  
  KUBE_USERNAME=tedi &&
  mkdir -p /home/${KUBE_USERNAME}/.kube &&
  cp /etc/kubernetes/admin.conf /home/${KUBE_USERNAME}/.kube/config &&
  chown ${KUBE_USERNAME}:${KUBE_USERNAME} -R /home/${KUBE_USERNAME}/.kube &&

  (su ${KUBE_USERNAME} <<\EOF
    set -x &&

#    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml | tee -a ${HOME}/pod_network_setup.txt &&
    # Install the plugin (CNI) for the Pod network. Calico - the only CNI implementation recommended and fully tested by the project Kubernetes
    kubectl apply -f https://docs.projectcalico.org/v3.15/manifests/calico.yaml 2>&1 | tee -a ${HOME}/pod_network_setup.txt &&

    set +x &&
    exit 0
EOF
  ) &&

  # Allow master(s) to run pods
  kubectl taint nodes --all node-role.kubernetes.io/master- &&

  # Join a worker node to the master cluster, by running this as root on the worker
#  kubeadm join \
#    A.B.C.D:6443 \
#    --token y9df3o.rqaytz43i3s0f35a \
#    --discovery-token-ca-cert-hash \
#      sha256:7b3b489f04d536a68baa1e3178c265c38bc0e3433473fde7c821412851ca7573 \
#    &&


  set +x &&
  exit 0
) &&
exit 0
# ============================================================================ #