#!/bin/sh
# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
if [ ${debug_jobs} -eq 1 ]
then
  set -x &&
  whoami &&
  echo "Cleaning up..." &&
  echo "${@}"
fi &&

container_name="gitlab-runner" &&
container_name="${container_name}--id-${CUSTOM_ENV_CI_RUNNER_ID}" &&
container_name="${container_name}--ns-${CUSTOM_ENV_CI_PROJECT_ROOT_NAMESPACE}" &&
container_name="${container_name}--project-${CUSTOM_ENV_CI_PROJECT_TITLE}" &&
container_name="${container_name}--commit-${CUSTOM_ENV_CI_COMMIT_SHA}" &&
container_name="${container_name}--job-${CUSTOM_ENV_CI_JOB_ID}" &&

podman stop \
  -t0 \
  ${container_name} \
  &&
rm -rf ${CUSTOM_ENV_CI_PROJECT_DIR}/${CUSTOM_ENV_CI_JOB_ID} &&

if [ ${debug_jobs} -eq 1 ]
then
  set +x
fi &&
exit 0
# ============================================================================ #

