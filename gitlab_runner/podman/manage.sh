#!/bin/bash
# ============================================================================ #
# Author(s):
# - Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
should_debug=0 &&
should_debug=1 && # Uncomment to enable debugging
# Start debugging
[ ${should_debug} -eq 1 ] && set -x || true &&
script_dir="$( cd $( dirname ${0} ) && pwd )" &&
# Get version like: "17.1.1" from this URL:
# https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest
#   /index.html
# https://docs.gitlab.com/runner/install/linux-manually.html
version="17.2.1" &&
. ${script_dir}/env.vars &&
container_install_path="/root/gitlab_runner" &&
outside_install_path="${script_dir}/fs${container_install_path}" &&
gitlab_runner_bin="${container_install_path}/bin/${version}/gitlab-runner" &&
config_path="${container_install_path}/cfg/config.toml" &&
container_name="gitlab_runner" &&

# This container cmd is used as a prefix before invoking the runner
ccmd="--rm" &&
ccmd="${ccmd} --name ${container_name}" &&
ccmd="${ccmd} --cap-add=sys_admin,mknod" &&
ccmd="${ccmd} --device=/dev/fuse" &&
ccmd="${ccmd} --security-opt apparmor=unconfined" &&
ccmd="${ccmd} --entrypoint /root/entrypoint.sh" &&
#ccmd="${ccmd} --entrypoint /bin/bash" &&
ccmd="${ccmd} --env container_install_path=${container_install_path}" &&
ccmd="${ccmd} --env debug_jobs=${debug_jobs}" &&
ccmd="${ccmd} --env gitlab_runner_bin=${gitlab_runner_bin}" &&
ccmd="${ccmd} --volume ${script_dir}/fs/root/entrypoint.sh:" &&
ccmd="${ccmd}/root/entrypoint.sh:ro" &&
ccmd="${ccmd} --volume ${outside_install_path}/bin/${version}/gitlab-runner:" &&
ccmd="${ccmd}${gitlab_runner_bin}:ro" &&
ccmd="${ccmd} --volume ${outside_install_path}/cfg/config.toml:" &&
ccmd="${ccmd}${container_install_path}/cfg/config.toml:rw" &&
for f in prepare.sh run.sh cleanup.sh
do
  ccmd="${ccmd} --volume ${outside_install_path}/scripts/${f}:" &&
  ccmd="${ccmd}${container_install_path}/scripts/${f}:ro"
done &&
ccmd="${ccmd} gitlab_runner_podman:0.0.1" &&
ccmd_it="podman run -it ${ccmd}" &&
ccmd_d="podman run --detach ${ccmd}" &&


# ============================================================================ #
function ensure_config_file()
{
  mkdir -p ${outside_install_path}/cfg &&
  touch ${outside_install_path}/cfg/config.toml &&
  true
} &&
# ============================================================================ #
function ensure_container_image()
{
  podman build \
    --file ${script_dir}/Containerfile \
    --tag gitlab_runner_podman:0.0.1 \
    &&
  true
} &&
# ============================================================================ #
function ensure_gitlab_runner()
{
  if [ ! -d ${outside_install_path}/bin/${version} ]
  then
    mkdir -p ${outside_install_path}/bin/${version}
  fi &&
  if [ ! -f ${outside_install_path}/bin/${version}/gitlab-runner ]
  then
    # old source:
    # https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/
    #   latest/index.html
    # url="https://s3.dualstack.us-east-1.amazonaws.com" &&
    # url="${url}/${version}/gitlab-runner-downloads/latest" &&
    # url="${url}/gitlab-runner-linux-amd64" &&

    # new source - get automatically from RSS
    # https://gitlab.com/gitlab-org/gitlab-runner/-/releases
    url="https://gitlab.com/gitlab-org/gitlab-runner/-/releases/" &&
    url="${url}/v${version}/downloads/binaries/gitlab-runner-linux-amd64" &&
    curl -LJ "${url}" -o ${outside_install_path}/bin/${version}/gitlab-runner
  fi &&
  chmod u+x ${outside_install_path}/bin/${version}/gitlab-runner &&
  true
} &&
# ============================================================================ #
function ensure_runner_is_registered()
{
  # is_registered="$(${ccmd} ${gitlab_runner_bin} list --config ${config_path} |
  #   tail -n+3 | wc -l)" &&
  # if [ ${is_registered} -eq 0 ]
  ${ccmd_it} ${gitlab_runner_bin} \
    register \
    --config ${config_path} \
    --url "${gitlab_url}" \
    --description "${runner_name}" \
    --registration-token "${registration_token}" \
    \
    --non-interactive \
    --tag-list "${runner_tag_list}" \
    --run-untagged \
    --locked="false" \
    --builds-dir ${container_install_path}/builds_dir \
    --cache-dir ${container_install_path}/cache_dir \
    --executor custom \
    \
    --custom-prepare-exec "${container_install_path}/scripts/prepare.sh" \
    --custom-run-exec "${container_install_path}/scripts/run.sh" \
    --custom-cleanup-exec "${container_install_path}/scripts/cleanup.sh" \
    &&
  true
} &&
# ============================================================================ #
function ensure_runner_is_running()
{
  # Start runner
    # --user gitlab-runner
  ${ccmd_d} ${gitlab_runner_bin} \
    run \
    --config ${config_path} \
    --working-directory ${container_install_path}/working-directory \
    &&
  true
} &&
# ============================================================================ #






# ============================================================================ #
# Start the GitLab runner.
# ============================================================================ #
function start()
{
  ensure_config_file &&
  ensure_container_image &&
  ensure_gitlab_runner &&
  ensure_runner_is_registered &&
  ensure_runner_is_running &&
  true
} &&
# ============================================================================ #






# ============================================================================ #
# Stop the GitLab runner.
# ============================================================================ #
function stop()
{
  ensure_container_image &&
  podman stop ${container_name} &&
  ${ccmd_it} ${gitlab_runner_bin} \
    unregister \
    --config ${config_path} \
    --url "${gitlab_url}" \
    ` # This is actually the description parameter from the register command ` \
    --name "${runner_name}" \
    &&
  true
} &&
# ============================================================================ #






# ============================================================================ #
# Prints a help menu.
# ============================================================================ #
function print_help()
{
  echo "Usage:
  --start         Start the GitLab runner.
  --stop          Stop the GitLab runner.
  --help          Print this help menu.
  anything-else   Print this help menu." &&
  true
} &&
# ============================================================================ #





# ============================================================================ #
# Case logic
# ============================================================================ #
# If no parameter
if [ ${#} == 0 ]; then
  print_help
fi &&

# Case
first_param="${1}" &&
shift &&
exit_code=0 &&
if [ ${first_param} ]; then
  case "${first_param}" in
    --start) ${first_param#--} ${@} ; exit_code=${?} ;;
    --stop) ${first_param#--} ${@} ; exit_code=${?} ;;
    *) print_help ; exit_code=0 ;;
  esac
fi &&

# Stop debugging
[ ${should_debug} -eq 1 ] && set +x || true &&
exit ${exit_code}
# ============================================================================ #

