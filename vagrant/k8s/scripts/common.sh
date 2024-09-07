#!/bin/bash
# ============================================================================ #
# Authors:
# - Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# Common setup for all servers (Control Plane and Nodes)
# ============================================================================ #


# ============================================================================ #
# Global variables
# ============================================================================ #
should_debug=0 &&
should_debug=1 && # Uncomment to enable debugging
# Start debugging
[ ${should_debug} -eq 1 ] && set -euxo pipefail || true &&

script_dir="$( cd $( dirname ${0} ) && pwd )" &&
# ============================================================================ #





# ============================================================================ #
# Common things for all nodes
# ============================================================================ #
function common-all-nodes()
{
  echo "Ensure this is running as root ..." &&
  if [ $(id -u) -ne 0 ]
  then
    echo "This must run as root! Exiting with failure." &&
    return 1
  fi &&

  echo "Adding all nodes to /etc/hosts ..." &&
  for i in $(seq 1 ${NUM_CONTROL_NODES})
  do
    echo "${IP_NW}$((IP_START - 1 + i)) control-plane-${i}" >> /etc/hosts
  done &&
  for i in $(seq 1 ${NUM_WORKER_NODES})
  do
    echo "${IP_NW}$((IP_START - 1 + NUM_CONTROL_NODES + i)) worker-${i}" \
      >> /etc/hosts
  done &&
  cat /etc/hosts &&

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

  echo "Creating the .conf file to load the modules at bootup ..." &&
  ( cat <<EOF | tee /etc/modules-load.d/k8s.conf
  overlay
  br_netfilter
EOF
  ) &&
  modprobe overlay &&
  modprobe br_netfilter &&

  echo "Configuring required sysctl params, params persist across reboots ..."&&
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
    ` # Required for managing repositories ` \
    software-properties-common \
    curl \
    apt-transport-https \
    ca-certificates \
    ` # Required for getting the local IP ` \
    jq \
    yq \
    ` # Required for LongHorn persistent volume provisioner ` \
    open-iscsi \
    nfs-common \
    &&

  echo "Adding CRI-O repository ..." &&
  repo_url="https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/deb" &&
  curl -fsSL ${repo_url}/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg &&
  echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] ${repo_url}/ /"\
    | tee /etc/apt/sources.list.d/cri-o.list &&
  apt-get update -y &&

  echo "Installing CRI-O Runtime ..." &&
  apt-get install -y cri-o &&
  systemctl daemon-reload &&
  systemctl enable crio --now &&
  systemctl start crio.service &&

  echo "Adding K8s repository ..." &&
  mkdir -p /etc/apt/keyrings &&
  repo_url="https://pkgs.k8s.io/core:/stable:/v${KUBERNETES_VERSION_SHORT}" &&
  repo_url="${repo_url}/deb" &&
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

  true
} &&
# ============================================================================ #





# ============================================================================ #
# Install K8s Dashboard.
# ============================================================================ #
function dashboard()
{
  config_path="/vagrant/configs" &&

  DASHBOARD_VERSION="$(yq -r .software.dashboard /vagrant/settings.yml)" &&
  if [ "${DASHBOARD_VERSION}" == "null" ]
  then
    echo "K8s Dashboard will not be installed because you don't need it." &&
    exit 0
  fi &&

  while kubectl get pods -A -l k8s-app=metrics-server |
    awk 'split($3, a, "/") && a[1] != a[2] { print $0; }' | grep -v "RESTARTS"
  do
    echo "Waiting for metrics server to be ready..." &&
    sleep 1
  done &&
  echo "Metrics server is ready. Installing dashboard..." &&

  echo "Creating NS for K8s Dashboard ..." &&
  kubectl create namespace kubernetes-dashboard &&

  echo "Creating the dashboard user ..." &&
  ( cat <<EOF | kubectl apply -f -
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
  kubectl apply -f ${db_url} &&

  echo "Setting token TTL ..." &&
  token_ttl=$(yq .software.dashboard_token_ttl /vagrant/settings.yml) &&
  kubectl patch --namespace kubernetes-dashboard deployment \
    kubernetes-dashboard --type=json --patch \
   "[{'op':'add',
   'path':'/spec/template/spec/containers/0/args/-',
   'value':'--token-ttl=${token_ttl}'}]" &&

  echo "Saving dashboard access token ..." &&
  kubectl -n kubernetes-dashboard get secret/admin-user \
    -o go-template="{{.data.token | base64decode}}" > ${config_path}/token &&
  echo >> ${config_path}/token &&
  echo "The following token was also saved to: configs/token" &&
  cat ${config_path}/token &&
  echo "Use it to log in into the dashboard. You can kubectl port-forward the" \
    "service to access it in your browser." &&
  true
} &&
# ============================================================================ #





# ============================================================================ #
# Install LongHorn
# ============================================================================ #
function longhorn()
{
  config_path="/vagrant/configs" &&

  longhorn_version="$(yq -r .software.longhorn /vagrant/settings.yml)" &&
  if [ "${longhorn_version}" == "null" ]
  then
    echo "LongHorn will not be installed because you don't need it." &&
    exit 0
  fi &&

  echo "Deploying the LongHorn persistent volume provisioner ..." &&
  lh_url="https://raw.githubusercontent.com/longhorn/longhorn" &&
  lh_url="${lh_url}/v${longhorn_version}/deploy/longhorn.yaml" &&
  kubectl apply -f ${lh_url} &&

  echo "Waiting for LongHorn to start ..." &&
  # kubectl get pods --namespace longhorn-system --watch &&

  echo "LongHorn is ready. You can kubectl port-forward the service to it in" \
    "your browser." &&
  true
# To uninstall LongHorn:
# kubectl -n longhorn-system get lhs deleting-confirmation-flag &&
# kubectl -n longhorn-system patch -p '{"value": "true"}' --type=merge lhs \
#   deleting-confirmation-flag &&
# kubectl create -f \
#   https://raw.githubusercontent.com/longhorn/longhorn/v1.7.1/uninstall/\
#   uninstall.yaml &&
# kubectl get job/longhorn-uninstall -n longhorn-system -w &&
# kubectl delete -f https://raw.githubusercontent.com/longhorn/longhorn/v1.7.1\
#   /deploy/longhorn.yaml
# kubectl delete -f https://raw.githubusercontent.com/longhorn/longhorn/v1.7.1\
#   /uninstall/uninstall.yaml
} &&
# ============================================================================ #





# ============================================================================ #
# Prints a help menu.
# ============================================================================ #
function print-help()
{
  echo "Usage:
  --all             Run all.
  --dashboard       Install the K8s dashboard.
  --longhorn        Install LongHorn.
  --help            Print this help menu.
  anything-else     Print this help menu." &&
  true
} &&
# ============================================================================ #





# ============================================================================ #
# Case logic
# ============================================================================ #
# If no parameter
if [ ${#} == 0 ]
then
  print-help &&
  env &&
  common-all-nodes &&
  true
  exit 0
fi &&

# Case
first_param="${1}" &&
shift &&
exit_code=0 &&
if [ ${first_param} ]
then
  case "${first_param}" in
    --all) ${first_param#--} ${@} ; exit_code=${?} ;;
    --dashboard) ${first_param#--} ${@} ; exit_code=${?} ;;
    --longhorn) ${first_param#--} ${@} ; exit_code=${?} ;;
    *) print-help ; exit_code=0 ;;
  esac
fi &&

# Stop debugging
( [ ${should_debug} -eq 1 ] && set +x || true ) &&
exit ${exit_code}
# ============================================================================ #
