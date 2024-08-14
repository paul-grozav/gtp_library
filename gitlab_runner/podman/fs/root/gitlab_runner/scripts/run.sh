#!/bin/sh
# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# This gets executed multiple times for a job. The exact step is printed. These
# are the "stages" inside a job:
# - prepare_script - Prints Running on $(hostname)...
# - get_sources - Does a git clone to fetch project sources
# - build_script - Runs the actual commands the users wants to run
# - [optional] upload_artifacts_on_success - Uploads artifacts from runner to
#   GitLab instance
# - cleanup_file_variables - 
# ============================================================================ #
if [ ${debug_jobs} -eq 1 ]
then
  set -x &&
  whoami &&
  echo "Running...${2}" &&
  echo "${@}" &&
  cat ${1}
fi &&

container_name="gitlab-runner" &&
container_name="${container_name}--id-${CUSTOM_ENV_CI_RUNNER_ID}" &&
container_name="${container_name}--ns-${CUSTOM_ENV_CI_PROJECT_ROOT_NAMESPACE}" &&
container_name="${container_name}--project-${CUSTOM_ENV_CI_PROJECT_TITLE}" &&
container_name="${container_name}--commit-${CUSTOM_ENV_CI_COMMIT_SHA}" &&
container_name="${container_name}--job-${CUSTOM_ENV_CI_JOB_ID}" &&

cmd="${@}" &&
if [ "${2}" == "prepare_script" \
  -o "${2}" == "get_sources" \
  -o "${2}" == "download_artifacts" \
  -o "${2}" == "upload_artifacts_on_success" \
  -o "${2}" == "cleanup_file_variables" ]
then
  echo "Running job stage: ${2} on the runner container..." &&
  # Uploading/Downloading artifacts requires the gitlab-runner in path
  export PATH="${PATH}:$( dirname ${gitlab_runner_bin} )" &&
  # Getting sources is done locally, using local git.
  # container might not have git installed
  ${cmd}
else
#  -o "${2}" == "build_script" \
  echo "Running job stage: ${2} on the temporary job container..." &&
  sed -i 's/\/usr\/bin\/env bash/\/usr\/bin\/env sh/g' ${1} &&
  podman exec \
    -it \
    ${container_name} \
    /bin/sh -c "${cmd}"
fi &&

# ${1} ${2} &&

if [ ${debug_jobs} -eq 1 ]
then
  set +x
fi &&
exit 0
# ============================================================================ #

