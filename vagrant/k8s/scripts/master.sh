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

echo "Initializing control plane node ..." &&
kubeadm init \
  --apiserver-advertise-address=${CONTROL_IP} \
  --apiserver-cert-extra-sans=${CONTROL_IP} \
  --pod-network-cidr=${POD_CIDR} \
  --service-cidr=${SERVICE_CIDR} \
  --ignore-preflight-errors Swap \
  &&
  # --node-name $(hostname -s) \

echo "Copying kubeconfig to root's home folder ..." &&
mkdir -p ${HOME}/.kube &&
cp -i /etc/kubernetes/admin.conf ${HOME}/.kube/config &&
chown $(id -u):$(id -g) ${HOME}/.kube/config &&

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
kubeadm token create --print-join-command > ${config_path}/join.sh &&

echo "Installing Calico Network Plugin ..." &&
#curl https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/calico.yaml -O &&
#kubectl apply -f calico.yaml &&
calico_url="https://raw.githubusercontent.com/projectcalico/calico" &&
calico_url="${calico_url}/v${CALICO_VERSION}/manifests/calico.yaml" &&
kubectl apply -f ${calico_url} &&

echo "Installing Metrics Server ..." &&
metrics_url="https://raw.githubusercontent.com/techiescamp/kubeadm-scripts" &&
metrics_url="${metrics_url}/main/manifests/metrics-server.yaml" &&
kubectl apply -f ${metrics_url} &&

echo "Done setting up the control plane node!" &&
exit 0
# ============================================================================ #
