#!/bin/bash
# ============================================================================ #
# Authors:
# - Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# Setup for Node servers
# ============================================================================ #
set -euxo pipefail &&
env &&
config_path="/vagrant/configs" &&

echo "Downloading K8s images ..." &&
kubeadm config images pull &&

echo "Joining the node to the cluster ..." &&
/bin/bash -x ${config_path}/join_control_plane.sh -v &&

echo "Copying kubeconfig to root's home folder ..." &&
mkdir -p ${HOME}/.kube &&
cp -i ${config_path}/config ${HOME}/.kube/ &&
chown $(id -u):$(id -g) -R ${HOME}/.kube &&

echo "Copying kubeconfig to vagrant's home folder ..." &&
mkdir -p /home/vagrant/.kube &&
cp -i ${config_path}/config /home/vagrant/.kube/ &&
chown 1000:1000 -R /home/vagrant/.kube &&

exit 0
# ============================================================================ #
