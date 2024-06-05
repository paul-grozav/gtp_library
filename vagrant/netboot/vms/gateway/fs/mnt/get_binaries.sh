# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# Since version 5.10, a special PXELINUX binary, lpxelinux.0, natively supports
# HTTP and FTP transfers, greatly increasing load speed and allowing for
# standard HTTP scripts to present PXELINUX's configuration file.
# ============================================================================ #
set -x &&
# Current directory, where the script exists
current_directory="$(cd $(dirname $0); pwd)" &&

syslinux_version="6.03" &&
syslinux_folder="syslinux-${syslinux_version}" &&
syslinux_url="https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux" &&
syslinux_url="${syslinux_url}/${syslinux_folder}.tar.gz" &&

if [ ! -f ${current_directory}/${syslinux_folder}.tar.gz ]; then
  wget ${syslinux_url}
fi &&

pxe_syslinux_dir="${current_directory}/pxe_syslinux" &&
if [ ! -d ${pxe_syslinux_dir} ]; then
  mkdir -p ${pxe_syslinux_dir}
fi &&

rm -f \
  {${current_directory},${pxe_syslinux_dir}}/lpxelinux.0 \
  {${current_directory},${pxe_syslinux_dir}}/ldlinux.c32 \
  {${current_directory},${pxe_syslinux_dir}}/menu.c32 \
  {${current_directory},${pxe_syslinux_dir}}/libutil.c32 \
  {${current_directory},${pxe_syslinux_dir}}/pxechn.c32 \
  {${current_directory},${pxe_syslinux_dir}}/libcom32.c32 \
  {${current_directory},${pxe_syslinux_dir}}/memdisk \
  &&

# TFTP server points the client to start booting from /lpxelinux.0
# pxelinux.0 requires file /ldlinux.c32
# pxelinux.0 requires "configuration file": /pxelinux.cfg/default
tar xvf ${current_directory}/${syslinux_folder}.tar.gz --strip-components \
  3 ${syslinux_folder}/bios/core/lpxelinux.0 &&
#mv ${current_directory}/pxelinux.0 ${pxe_syslinux_dir} &&
tar xvf ${current_directory}/${syslinux_folder}.tar.gz --strip-components \
  5 ${syslinux_folder}/bios/com32/elflink/ldlinux/ldlinux.c32 &&
#mv ${current_directory}/ldlinux.c32 ${pxe_syslinux_dir} &&

# /pxelinux.cfg/default will require /menu.c32 to display the boot menu
# and /menu.c32 requires /libutil.c32 .
tar xvf ${current_directory}/${syslinux_folder}.tar.gz --strip-components \
  4 ${syslinux_folder}/bios/com32/menu/menu.c32 &&
mv ${current_directory}/menu.c32 ${pxe_syslinux_dir} &&
tar xvf ${current_directory}/${syslinux_folder}.tar.gz --strip-components \
  4 ${syslinux_folder}/bios/com32/libutil/libutil.c32 &&
#mv ${current_directory}/libutil.c32 ${pxe_syslinux_dir} &&

# Making one boot menu boot another pxelinux.0 file, requires /pxechn.c32
# and /pxechn.c32 requires /libcom32.c32 .
tar xvf ${current_directory}/${syslinux_folder}.tar.gz --strip-components \
  4 ${syslinux_folder}/bios/com32/modules/pxechn.c32 &&
mv ${current_directory}/pxechn.c32 ${pxe_syslinux_dir} &&
tar xvf ${current_directory}/${syslinux_folder}.tar.gz --strip-components \
  4 ${syslinux_folder}/bios/com32/lib/libcom32.c32 &&
#mv ${current_directory}/libcom32.c32 ${pxe_syslinux_dir} &&

# To make a boot entry load an .iso file we need memdisk
tar xvf ${current_directory}/${syslinux_folder}.tar.gz --strip-components \
  3 ${syslinux_folder}/bios/memdisk/memdisk &&
mv ${current_directory}/memdisk ${pxe_syslinux_dir} &&

rm -f ${current_directory}/${syslinux_folder}.tar.gz &&

set +x &&
exit 0
# ============================================================================ #

