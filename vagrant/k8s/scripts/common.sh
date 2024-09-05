#!/bin/bash
# ============================================================================ #
# Authors:
# - Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# Common setup for all servers (Control Plane and Nodes)
# ============================================================================ #
set -euxo pipefail &&
env &&
# Variable Declaration

echo "Configuring DNS settings ..." &&
mkdir -p /etc/systemd/resolved.conf.d &&
( cat <<EOF | tee /etc/systemd/resolved.conf.d/dns_servers.conf
[Resolve]
DNS=${DNS_SERVERS}
EOF
) &&
systemctl restart systemd-resolved &&

echo "Disabling swap ..." &&
swapoff -a &&

echo "Keeping the swap off during reboot ..." &&
(
  crontab -l 2>/dev/null ;
  echo "@reboot /sbin/swapoff -a"
) | crontab - || true &&

#apt-get update -y &&


echo "Creating the .conf file to load the modules at bootup ..." &&
( cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
) &&
modprobe overlay &&
modprobe br_netfilter &&

echo "Configuring required sysctl params, params persist across reboots ..." &&
( cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
) &&

echo "Applying sysctl params without reboot ..." &&
sysctl --system &&

echo "Installing basic packages ..." &&
export DEBIAN_FRONTEND=noninteractive &&
apt-get update -y &&
apt-get install -y \
  software-properties-common \
  curl \
  apt-transport-https \
  ca-certificates \
  jq \
  &&

echo "Adding CRI-O repository ..." &&
repo_url="https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/deb" &&
curl -fsSL ${repo_url}/Release.key |
  gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg &&
echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] ${repo_url}/ /" |
  tee /etc/apt/sources.list.d/cri-o.list &&
apt-get update -y &&

echo "Installing CRI-O Runtime ..." &&
apt-get install -y cri-o &&
systemctl daemon-reload &&
systemctl enable crio --now &&
systemctl start crio.service &&

echo "Adding K8s repository ..." &&
mkdir -p /etc/apt/keyrings &&
repo_url="https://pkgs.k8s.io/core:/stable:/v${KUBERNETES_VERSION_SHORT}/deb" &&
curl -fsSL ${repo_url}/Release.key |
  gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg &&
echo "deb" \
  "[signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] ${repo_url}/ /" |
  tee /etc/apt/sources.list.d/kubernetes.list &&
apt-get update -y &&

echo "Installing K8s ..." &&
apt-get install -y \
  kubelet=${KUBERNETES_VERSION} \
  kubectl=${KUBERNETES_VERSION} \
  kubeadm=${KUBERNETES_VERSION} \
  &&

echo "Disable auto-update services for CRI-O and K8s ..." &&
apt-mark hold kubelet kubectl kubeadm cri-o &&

echo "Setting local ip as extra kubelet arg ..." &&
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
( cat > /etc/default/kubelet << EOF
KUBELET_EXTRA_ARGS=--node-ip=${local_ip}
${ENVIRONMENT}
EOF
) &&
exit 0
# ============================================================================ #
