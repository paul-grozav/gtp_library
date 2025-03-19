#!/bin/bash
# ============================================================================ #
# Authors:
# - Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
script_dir="$( cd $( dirname ${0} ) && pwd )" &&
openbsd_url="https://ftp.openbsd.org/pub/OpenBSD/7.6/amd64" &&
tftp_root="/srv/tftp" &&
wget ${openbsd_url}/pxeboot -O ${tftp_root}/auto_install &&
wget ${openbsd_url}/bsd.rd -O ${tftp_root}/bsd.rd &&
mkdir -p ${tftp_root}/etc &&
cp ${script_dir}/boot.conf ${tftp_root}/etc/boot.conf &&
dd \
  if=/dev/random \
  of=${tftp_root}/etc/random.seed \
  bs=512 \
  count=1 \
  status=none \
  &&
exit 0
# ============================================================================ #
