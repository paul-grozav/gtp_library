#!/bin/bash
# ============================================================================ #
# Authors:
# - Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# nano ./settings.yml
# ${0} --lb-start
# vagrant up
# ============================================================================ #


# ============================================================================ #
# Global variables
# ============================================================================ #
should_debug=0 &&
should_debug=1 && # Uncomment to enable debugging
# Start debugging
[ ${should_debug} -eq 1 ] && set -euxo pipefail || true &&
exit_code=0 &&
config_path="/vagrant/configs" &&
lb_container_name="haproxy-k8s" &&
lb_container_image="docker.io/haproxy:3.0.4-alpine3.20" &&

# Dynamic variables
script_dir="$( cd $( dirname ${0} ) && pwd )" &&
cmgr="$( command -v podman &> /dev/null && echo podman || echo docker )" &&
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
  end" \
  || true
)" &&
# ============================================================================ #





# ============================================================================ #
# Start the LoadBalancer container on the host where VM(s) run. This is only
# required if you need an Highly Available (HA) K8s cluster, to balance the
# requests to the control plane nodes.
# ============================================================================ #
function lb-start()
{
  ${cmgr} run \
    -d \
    --rm \
    --name ${lb_container_name} \
    -v ${script_dir}/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro \
    -p 6443:6443/tcp \
    ${lb_container_image} \
    /bin/sh -c "
      echo Checking cofiguration ... &&
      haproxy -c \
        -f /usr/local/etc/haproxy/haproxy.cfg \
        &&
      echo Starting HAProxy load balancer ... &&
      haproxy \
        -f /usr/local/etc/haproxy/haproxy.cfg \
    " \
    &&
  true
} &&
# ============================================================================ #





# ============================================================================ #
# Stop the LoadBalancer container on the host where VM(s) run.
# ============================================================================ #
function lb-stop()
{
  ${cmgr} stop ${lb_container_name} &&
  ${cmgr} rm ${lb_container_name} &&
  true
} &&
# ============================================================================ #





# ============================================================================ #
# Show the LoadBalancer container logs.
# ============================================================================ #
function lb-logs()
{
  ${cmgr} logs -f ${lb_container_name} &&
  true
} &&
# ============================================================================ #





# ============================================================================ #
# Configure a generic vagrant box.
# ============================================================================ #
function config-generic-box()
{
  # env > ${HOME}/env.env &&
  common-all-nodes &&
  CONTROL_IP="$(yq -r .network.control_ip /vagrant/settings.yml)" &&

  # Check if the IP of this machine is in range
  local_ip_net="$( echo ${local_ip} | awk -F. '{print $1"."$2"."$3"."}' )" &&
  control_ip_net="$( echo ${CONTROL_IP} | awk -F. '{print $1"."$2"."$3"."}' )"&&
  if [ "${local_ip_net}" != "${control_ip_net}" ]
  then
    echo "Error: Local IP: ${local_ip} is not in the expected range:" \
      ${CONTROL_IP}"/24. So, IDK if this is a control plane or worker node." &&
    return 1
  fi &&
  local_ip_octet=$( echo ${local_ip} | awk -F. '{print $4}' ) &&
  control_ip_octet=$( echo ${CONTROL_IP} | awk -F. '{print $4}' ) &&

  # Print IP allocation plan
  echo "IP(s) are starting at: ${CONTROL_IP} , octet: ${control_ip_octet}" &&
  echo &&
  echo "${NUM_CONTROL_NODES} IP(s) allocated for control-plane nodes." &&
  cp_first_octet=${control_ip_octet} &&
  echo "First octet:" $(( ${cp_first_octet} )) &&
  cp_last_octet=$(( ${control_ip_octet} - 1 + ${NUM_CONTROL_NODES} )) &&
  echo "Last octet:" ${cp_last_octet} &&
  echo &&
  echo "${NUM_WORKER_NODES} IP(s) allocated for worker nodes." &&
  wrk_first_octet=$(( ${control_ip_octet} + ${NUM_CONTROL_NODES} )) &&
  echo "First octet:" ${wrk_first_octet} &&
  wrk_last_octet=$(( ${control_ip_octet} - 1 + ${NUM_CONTROL_NODES} \
    + ${NUM_WORKER_NODES} )) &&
  echo "Last octet:" ${wrk_last_octet} &&

  # Identify machine type and configure it.
  if [ ${local_ip_octet} -eq ${control_ip_octet} ]
  then
    echo "This is the first control plane node. I will start configuring" \
      "it ..." &&
    control-plane-first
  fi &&

  # + 1 because the first control plane was created above
  if [ $(( ${cp_first_octet} + 1 )) -le ${local_ip_octet} ] \
    && [ ${local_ip_octet} -le ${cp_last_octet} ]
  then
    echo "This is the a subsequent control plane node. I will start" \
      "configuring it ..." &&
    control-plane-subsequent
  fi &&

  if [ ${wrk_first_octet} -le ${local_ip_octet} ] \
    && [ ${local_ip_octet} -le ${wrk_last_octet} ]
  then
    echo "This is the a worker node. I will start configuring it ..." &&
    worker
  fi &&

  echo "Done configuring the generic box!" &&
  true
} &&
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
    exit_code=1 &&
    exit ${exit_code}
  fi &&

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

  echo "Adding all nodes to /etc/hosts ..." &&
  IP_NW="$(yq -r .network.control_ip /vagrant/settings.yml |
    awk -F'.' '{print $1"."$2"."$3"."}')" &&
  IP_START="$(yq -r .network.control_ip /vagrant/settings.yml |
    awk -F'.' '{print $4}')" &&
  NUM_CONTROL_NODES="$(yq -r .nodes.control.count /vagrant/settings.yml)" &&
  NUM_WORKER_NODES="$(yq -r .nodes.workers.count /vagrant/settings.yml)" &&
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
  DNS_SERVERS="$(yq -r ".network.dns_servers | join(\" \")" \
    /vagrant/settings.yml)" &&
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

  echo "Configuring required sysctl params (persists across reboots) ..." &&
  ( cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
  ) &&

  echo "Applying sysctl params without reboot ..." &&
  sysctl --system &&

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
  KUBERNETES_VERSION="$(yq -r .software.kubernetes /vagrant/settings.yml)" &&
  KUBERNETES_VERSION_SHORT="$(echo "${KUBERNETES_VERSION}" | cut -c-4)" &&
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
  ENVIRONMENT="$(yq -r .environment /vagrant/settings.yml)" &&
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

  # echo "Waiting for LongHorn to start ..." &&
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
# Configure the 1st control plane node.
# ============================================================================ #
function control-plane-first()
{
  echo "Downloading K8s images ..." &&
  kubeadm config images pull &&

  echo "Initializing control plane node ..." &&
  POD_CIDR="$(yq -r .network.pod_cidr /vagrant/settings.yml)" &&
  SERVICE_CIDR="$(yq -r .network.service_cidr /vagrant/settings.yml)" &&
  kubeadm init \
    --v 5 \
    --ignore-preflight-errors Swap \
    --upload-certs \
    ` # This points to the LoadBalancer that balances between the control ` \
    ` # plane IPs, on destination port 6443. This is where the other nodes ` \
    ` # will connect when they join the cluster. ` \
    --control-plane-endpoint 192.168.0.12:6443 \
    ` # If you only have one control plane node, you can use it's IP as the ` \
    ` # cp endpoint param. ` \
    ` # --control-plane-endpoint ${CONTROL_IP}:6443 ` \
    --pod-network-cidr ${POD_CIDR} \
    --service-cidr ${SERVICE_CIDR} \
    ` # This is required because the VM has 2 interfaces, and by default ` \
    ` # kubeadm selects the one with the default route to the gateway. ` \
    ` # In Vagrant's case, that is the "IPMI" control interface eth0 . We ` \
    ` # want to use the second interface: eth1 . This IP is where the other ` \
    ` # nodes that join the cluster, are going to connect to etcd for ` \
    ` # example (to join/form the etcd cluster). ` \
    --apiserver-advertise-address ${local_ip} \
    &&
    # --apiserver-cert-extra-sans 192.168.0.12 \
    #
    # --node-name $(hostname -s) \
    # --image-repository registry.example.com/my_containers \

  echo "Copying kubeconfig to root's home folder ..." &&
  mkdir -p ${HOME}/.kube &&
  cp -i /etc/kubernetes/admin.conf ${HOME}/.kube/config &&
  chown $(id -u):$(id -g) -R ${HOME}/.kube &&

  echo "Copying kubeconfig to vagrant's home folder ..." &&
  mkdir -p /home/vagrant/.kube &&
  cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config &&
  chown 1000:1000 -R /home/vagrant/.kube &&

  echo "Saving Configs to shared Vagrant storage ..." &&
  mkdir -p ${config_path} &&
  # For Vagrant re-runs, check if there is existing configs in the location and
  # delete it for saving new configuration.
  rm -f ${config_path}/* &&
  cp -i /etc/kubernetes/admin.conf ${config_path}/config &&
  (
    echo -n $( kubeadm token create --print-join-command ) &&
    echo -n " --v 5" &&
    true
  ) > ${config_path}/join_worker.sh &&
  (
    echo -n "$(cat ${config_path}/join_worker.sh)" &&
    echo -n " --control-plane --certificate-key " &&
    kubeadm init phase upload-certs --upload-certs |
      grep -v "^\[upload-certs\] " &&
    true
  ) > ${config_path}/join_control_plane.sh &&

  schedule=$(yq .nodes.control.schedule /vagrant/settings.yml) &&
  if [ "${schedule}" == "true" ]
  then
    ( kubectl taint nodes --all node-role.kubernetes.io/control-plane- ||
      true ) &&
    true
  fi &&

  echo "Installing Calico Network Plugin ..." &&
  CALICO_VERSION="$(yq -r .software.calico /vagrant/settings.yml)" &&
  calico_url="https://raw.githubusercontent.com/projectcalico/calico" &&
  calico_url="${calico_url}/v${CALICO_VERSION}/manifests/calico.yaml" &&
  kubectl apply -f ${calico_url} &&

  echo "Installing Metrics Server ..." &&
  metrics_url="https://raw.githubusercontent.com/techiescamp/kubeadm-scripts" &&
  metrics_url="${metrics_url}/main/manifests/metrics-server.yaml" &&
  kubectl apply -f ${metrics_url} &&

  dashboard &&
  longhorn &&

  echo "Done setting up the control plane node!" &&
  true
} &&
# ============================================================================ #





# ============================================================================ #
# Configure the additional control plane node(s).
# ============================================================================ #
function control-plane-subsequent()
{
  echo "Downloading K8s images ..." &&
  kubeadm config images pull &&

  echo "Joining the node to the cluster ..." &&
  (
    echo -n $(cat ${config_path}/join_control_plane.sh) &&
    echo -n " --apiserver-advertise-address ${local_ip}" &&
    true
  ) | /bin/bash -x &&

  echo "Copying kubeconfig to root's home folder ..." &&
  mkdir -p ${HOME}/.kube &&
  cp -i ${config_path}/config ${HOME}/.kube/ &&
  chown $(id -u):$(id -g) -R ${HOME}/.kube &&

  echo "Copying kubeconfig to vagrant's home folder ..." &&
  mkdir -p /home/vagrant/.kube &&
  cp -i ${config_path}/config /home/vagrant/.kube/ &&
  chown 1000:1000 -R /home/vagrant/.kube &&
  true
} &&
# ============================================================================ #





# ============================================================================ #
# Configure the worker node(s).
# ============================================================================ #
function worker()
{
  # Workers don't need to pull images

  echo "Joining the node to the cluster ..." &&
  /bin/bash -x ${config_path}/join_worker.sh &&

  echo "Copying kubeconfig to root's home folder ..." &&
  mkdir -p ${HOME}/.kube &&
  cp -i ${config_path}/config ${HOME}/.kube/ &&
  chown $(id -u):$(id -g) -R ${HOME}/.kube &&

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
  true
} &&
# ============================================================================ #





# ============================================================================ #
# Prints a help menu.
# ============================================================================ #
function print-help()
{
  echo "Usage:
  --lb-start                   Start LoadBalancer container.
  --lb-stop                    Stop LoadBalancer container.
  --lb-logs                    Show the LoadBalancer container logs.
  --config-generic-box         Configure a generic box.
  --common-all-nodes           Run setup that is common for all nodes.
  --control-plane-first        Configure the 1st control plane node.
  --dashboard                  Install the K8s dashboard.
  --longhorn                   Install LongHorn.
  --control-plane-subsequent   Configure additional control plane node(s).
  --worker                     Configure worker node(s).
  --help                       Print this help menu.
  anything-else                Print this help menu." &&
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
  exit 1
fi &&

# Case
first_param="${1}" &&
shift &&
if [ ${first_param} ]
then
  case "${first_param}" in
    --lb-start) ${first_param#--} ${@} ; exit_code=${?} ;;
    --lb-stop) ${first_param#--} ${@} ; exit_code=${?} ;;
    --lb-logs) ${first_param#--} ${@} ; exit_code=${?} ;;
    --config-generic-box) ${first_param#--} ${@} ; exit_code=${?} ;;
    --common-all-nodes) ${first_param#--} ${@} ; exit_code=${?} ;;
    --control-plane-first) ${first_param#--} ${@} ; exit_code=${?} ;;
    --dashboard) ${first_param#--} ${@} ; exit_code=${?} ;;
    --longhorn) ${first_param#--} ${@} ; exit_code=${?} ;;
    --control-plane-subsequent) ${first_param#--} ${@} ; exit_code=${?} ;;
    --worker) ${first_param#--} ${@} ; exit_code=${?} ;;
    *) print-help ; exit_code=0 ;;
  esac
fi &&

# Stop debugging
( [ ${should_debug} -eq 1 ] && set +x || true ) &&
exit ${exit_code}
# ============================================================================ #
