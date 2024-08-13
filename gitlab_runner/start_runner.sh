#!/bin/bash
# ============================================================================ #
# Author(s):
# - Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
set -x &&
script_dir="$( cd $( dirname ${0} ) && pwd )" &&

# ============================================================================ #
function ensure_gitlab_runner()
{
  # Get version like: "17.1.1" from this URL:
  # https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest
  #   /index.html
  # https://docs.gitlab.com/runner/install/linux-manually.html
  version="17.2.1" &&
  if [ ! -d ${script_dir}/bin/${version} ]
  then
    mkdir -p ${script_dir}/bin/${version}
  fi &&
  if [ ! -f ${script_dir}/bin/${version}/gitlab-runner ]
  then
    # old source:
    # https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/index.html
    # url="https://s3.dualstack.us-east-1.amazonaws.com" &&
    # url="${url}/${version}/gitlab-runner-downloads/latest/gitlab-runner-linux-amd64" &&
    # new source - get automatically from RSS
    # https://gitlab.com/gitlab-org/gitlab-runner/-/releases
    url="https://gitlab.com/gitlab-org/gitlab-runner/-/releases/" &&
    url="${url}/v${version}/downloads/binaries/gitlab-runner-linux-amd64" &&
    curl -LJ "${url}" -o ${script_dir}/bin/${version}/gitlab-runner
  fi &&
  chmod u+x ${script_dir}/bin/${version}/gitlab-runner &&
  true
} && ensure_gitlab_runner &&
# ============================================================================ #
function ensure_gitlab_runner_is_running()
{
  exit 0
  podman run \
    --detach \
    --name gitlab-runner \
    --cap-add=sys_admin,mknod \
    --device=/dev/fuse \
    --security-opt apparmor=unconfined \
    --entrypoint /root/entrypoint.sh \
    --volume $(pwd)/bin/15.11.0/gitlab-runner-linux-amd64:/root/gitlab-runner:ro \
    --volume $(pwd)/podman/prepare.sh:/etc/gitlab-runner/prepare.sh:ro \
    --volume $(pwd)/podman/run.sh:/etc/gitlab-runner/run.sh:ro \
    --volume $(pwd)/podman/cleanup.sh:/etc/gitlab-runner/cleanup.sh:ro \
    --volume $(pwd)/podman/config.toml:/etc/gitlab-runner/config.toml:ro \
    --volume $(pwd)/podman/entrypoint.sh:/root/entrypoint.sh:ro \
    quay.io/podman/stable:v4.5.0 \
    &&

  # Runner params
  echo register \
  --url "https://gitlab.com/" \
  --registration-token "SECRET_TOKEN" \
  --description "alice-runner-podman" \
  \
  --non-interactive \
  --tag-list "container,linux,podman" \
  --run-untagged \
  --locked="false" \
  --executor custom \
  \
  --builds-dir /home/user \
  --cache-dir /home/user/cache \
  --custom-prepare-exec "/home/gitlab-runner/podman-gitlab-runner/prepare.sh" \
  --custom-run-exec "/home/gitlab-runner/podman-gitlab-runner/run.sh" \
  --custom-cleanup-exec "/home/gitlab-runner/podman-gitlab-runner/cleanup.sh"

  true
} && ensure_gitlab_runner_is_running &&
# ============================================================================ #



true
# ============================================================================ #
