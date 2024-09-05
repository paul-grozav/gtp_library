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

echo "Joining the node to the cluster ..." &&
/bin/bash -x ${config_path}/join.sh -v &&

echo "Copying kubeconfig to vagrant's home folder ..." &&
mkdir -p /home/vagrant/.kube &&
cp -i ${config_path}/config /home/vagrant/.kube/ &&
chown 1000:1000 -R /home/vagrant/.kube &&

echo "Labeling the worker node ..." &&
kubectl \
  --kubeconfig ${config_path}/config \
  label node $(hostname -s) \
  node-role.kubernetes.io/worker=worker \
  &&

exit 0
# ============================================================================ #
