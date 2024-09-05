#!/bin/bash
# ============================================================================ #
# Authors:
# - Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# Deploys the Kubernetes dashboard when enabled in settings.yml
# ============================================================================ #
set -euxo pipefail &&
env &&
config_path="/vagrant/configs" &&

DASHBOARD_VERSION=$(grep -E '^\s*dashboard:' /vagrant/settings.yml |
  sed -E -e 's/[^:]+: *//' -e 's/\r$//') &&
if [ -n "${DASHBOARD_VERSION}" ]
then
  vkubectl="sudo -i -u vagrant kubectl" &&
  while ${vkubectl} get pods -A -l k8s-app=metrics-server |
    awk 'split($3, a, "/") && a[1] != a[2] { print $0; }' | grep -v "RESTARTS"
  do
    echo "Waiting for metrics server to be ready..." &&
    sleep 1
  done &&
  echo "Metrics server is ready. Installing dashboard..." &&

  echo "Creating NS for K8s Dashboard ..." &&
  ${vkubectl} create namespace kubernetes-dashboard &&

  echo "Creating the dashboard user ..." &&
  ( cat <<EOF | ${vkubectl} apply -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: admin-user
---
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

  echo "Deploying the dashboard ..." &&
  db_url="https://raw.githubusercontent.com/kubernetes/dashboard" &&
  db_url="${db_url}/v${DASHBOARD_VERSION}/aio/deploy/recommended.yaml" &&
  ${vkubectl} apply -f ${db_url} &&

  echo "Saving dashboard access token ..." &&
  ${vkubectl} -n kubernetes-dashboard get secret/admin-user \
    -o go-template="{{.data.token | base64decode}}" >> ${config_path}/token &&
  echo "The following token was also saved to: configs/token" &&
  cat ${config_path}/token &&
  echo "
Use it to log in into the dashboard. You can kubectl port-forward the service to
access it in your browser.
" &&
  true
else
  echo "K8s Dashboard will not be installed."
fi &&
exit 0
# ============================================================================ #
