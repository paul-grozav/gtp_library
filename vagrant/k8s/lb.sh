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
[ ${should_debug} -eq 1 ] && set -x || true &&

script_dir="$( cd $( dirname ${0} ) && pwd )" &&
# ============================================================================ #





# ============================================================================ #
# Start LB
# ============================================================================ #
function start()
{
#  ( cat > /etc/default/kubelet << EOF
#  KUBELET_EXTRA_ARGS=--node-ip=${local_ip}
#  ${ENVIRONMENT}
#EOF
#  ) &&

  podman run \
    -it \
    --rm \
    --name haproxy-syntax-check \
    -v ${script_dir}/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro \
    docker.io/haproxy:3.0.4-alpine3.20 \
    haproxy -c \
    -f /usr/local/etc/haproxy/haproxy.cfg \
    &&

  podman run \
    -d \
    --rm \
    --name haproxy-k8s \
    -v ${script_dir}/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro \
    -p 6443:6443/tcp \
    docker.io/haproxy:3.0.4-alpine3.20 \
    haproxy \
    -f /usr/local/etc/haproxy/haproxy.cfg \
    &&
  true
} &&
# ============================================================================ #





# ============================================================================ #
# Stop LB
# ============================================================================ #
function stop()
{
  podman stop haproxy-k8s &&
  podman rm haproxy-k8s &&
  true
} &&
# ============================================================================ #





# ============================================================================ #
# Logs LB
# ============================================================================ #
function logs()
{
  podman logs -f haproxy-k8s &&
  true
} &&
# ============================================================================ #





# ============================================================================ #
# Prints a help menu.
# ============================================================================ #
function print-help()
{
  echo "Usage:
  --start           Start LB.
  --stop            Stop LB.
  --logs            Follow logs.
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
  exit 0
fi &&

# Case
first_param="${1}" &&
shift &&
exit_code=0 &&
if [ ${first_param} ]
then
  case "${first_param}" in
    --start) ${first_param#--} ${@} ; exit_code=${?} ;;
    --stop) ${first_param#--} ${@} ; exit_code=${?} ;;
    --logs) ${first_param#--} ${@} ; exit_code=${?} ;;
    *) print-help ; exit_code=0 ;;
  esac
fi &&

# Stop debugging
( [ ${should_debug} -eq 1 ] && set +x || true ) &&
exit ${exit_code}
# ============================================================================ #
