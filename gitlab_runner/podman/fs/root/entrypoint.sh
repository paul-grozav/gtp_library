#!/bin/bash
# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
set -x &&
mkdir -p ${container_install_path}/working-directory &&
mkdir -p ${container_install_path}/builds_dir &&
mkdir -p ${container_install_path}/cache_dir &&
exec "${@}" &&
exit 0
# ============================================================================ #
