#!/bin/bash
# ============================================================================ #
# Authors:
# - Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
script_dir="$( cd $( dirname ${0} ) && pwd )" &&
# openbsd_url="https://ftp.openbsd.org/pub/OpenBSD/7.6/amd64" &&
openbsd_url="https://mirrors.pidginhost.com/pub/OpenBSD/7.6/amd64" &&
http_root="/var/www/html" &&
cp ${script_dir}/08\:00\:27\:00\:00\:03-install.conf \
  ${http_root}/08\:00\:27\:00\:00\:03-install.conf &&
mkdir -p ${http_root}/OpenBSD/7.6/amd64 &&
(
  cd ${http_root}/OpenBSD/7.6/amd64 &&
  # wget \
  #   -nH \
  #   -P ${http_root}/OpenBSD/7.6/amd64 \
  #   --mirror \
  #   --cut-dirs=5 \
  #   --reject fs,img,iso \
  #   ${openbsd_url}/ \
  #   &&
  # This is the list that is hardcoded in *-install.conf files
  sets="index.txt BUILDINFO SHA256.sig" &&
  sets="${sets} bsd bsd.rd bsd.mp" &&
  sets="${sets} base76.tgz comp76.tgz man76.tgz game76.tgz" &&
  for set in ${sets} 
  do
    wget ${openbsd_url}/${p} -O ${http_root}/OpenBSD/7.6/amd64/${set} &&
    true
  done &&
  true
) &&
exit 0
# ============================================================================ #
