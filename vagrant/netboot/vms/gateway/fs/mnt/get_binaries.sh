# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# Since version 5.10, a special PXELINUX binary, lpxelinux.0, natively supports
# HTTP and FTP transfers, greatly increasing load speed and allowing for
# standard HTTP scripts to present PXELINUX's configuration file.
# See: https://datatracker.ietf.org/doc/html/rfc4578#section-2.1
#
# $ sudo cp /mnt/get_binaries.sh /srv/tftp/ &&
#   ( cd /srv/tftp && sudo bash -x ./get_binaries.sh )
# ============================================================================ #
set -x &&
# Current directory, where the script exists
current_directory="$(cd $(dirname $0); pwd)" &&

syslinux_version="6.02" &&
syslinux_folder="syslinux-${syslinux_version}" &&
syslinux_url="https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux" &&
syslinux_url="${syslinux_url}/${syslinux_folder}.tar.gz" &&

if [ ! -f ${current_directory}/${syslinux_folder}.tar.gz ]; then
  wget ${syslinux_url}
fi &&

#pxe_syslinux_dir="${current_directory}/pxe_syslinux" &&
#if [ ! -d ${pxe_syslinux_dir} ]; then
#  mkdir -p ${pxe_syslinux_dir}
#fi &&

rm -f \
  {${current_directory},${pxe_syslinux_dir}}/lpxelinux.0 \
  {${current_directory},${pxe_syslinux_dir}}/ldlinux.c32 \
  {${current_directory},${pxe_syslinux_dir}}/menu.c32 \
  {${current_directory},${pxe_syslinux_dir}}/libutil.c32 \
  {${current_directory},${pxe_syslinux_dir}}/pxechn.c32 \
  {${current_directory},${pxe_syslinux_dir}}/libcom32.c32 \
  {${current_directory},${pxe_syslinux_dir}}/memdisk \
  &&

# ============================================================================ #
# This is for clients booting from the Legacy BIOS firmware(ROM)
function Intel_x86PC__clients()
{
  destination="${current_directory}/syslinux/Intel_x86PC" &&
  mkdir -p ${destination} &&
  # TFTP server points the client to start booting from /lpxelinux.0
  # pxelinux.0 requires file /ldlinux.c32
  # pxelinux.0 requires "configuration file": /pxelinux.cfg/default
  # we could also extract the file to a destination path with a different file
  # name by using --transform 's/lpxelinux.0/new_name.bin/'
  tar xvf ${current_directory}/${syslinux_folder}.tar.gz \
    -C ${destination} \
    --strip-components 3 ${syslinux_folder}/bios/core/lpxelinux.0 &&
  tar xvf ${current_directory}/${syslinux_folder}.tar.gz \
    -C ${destination} \
    --strip-components 5 \
    ${syslinux_folder}/bios/com32/elflink/ldlinux/ldlinux.c32 \
    &&
  ln -s ${current_directory}/pxelinux.cfg ${destination} &&

  # /pxelinux.cfg/default will require /menu.c32 to display the boot menu
  # and /menu.c32 requires /libutil.c32 .
#  tar xvf ${current_directory}/${syslinux_folder}.tar.gz --strip-components \
#    4 ${syslinux_folder}/bios/com32/menu/menu.c32 &&
#  mv ${current_directory}/menu.c32 ${pxe_syslinux_dir} &&
#  tar xvf ${current_directory}/${syslinux_folder}.tar.gz --strip-components \
#    4 ${syslinux_folder}/bios/com32/libutil/libutil.c32 &&
  #mv ${current_directory}/libutil.c32 ${pxe_syslinux_dir} &&

  # Making one boot menu boot another pxelinux.0 file, requires /pxechn.c32
  # and /pxechn.c32 requires /libcom32.c32 .
#  tar xvf ${current_directory}/${syslinux_folder}.tar.gz --strip-components \
#    4 ${syslinux_folder}/bios/com32/modules/pxechn.c32 &&
#  mv ${current_directory}/pxechn.c32 ${pxe_syslinux_dir} &&
#  tar xvf ${current_directory}/${syslinux_folder}.tar.gz --strip-components \
#    4 ${syslinux_folder}/bios/com32/lib/libcom32.c32 &&
  #mv ${current_directory}/libcom32.c32 ${pxe_syslinux_dir} &&

  # To make a boot entry load an .iso file we need memdisk
#  tar xvf ${current_directory}/${syslinux_folder}.tar.gz --strip-components \
#    3 ${syslinux_folder}/bios/memdisk/memdisk &&
#  mv ${current_directory}/memdisk ${pxe_syslinux_dir} &&
  true
} && Intel_x86PC__clients &&
# ============================================================================ #



# ============================================================================ #
function EFI_IA32__clients()
{
  destination="${current_directory}/syslinux/EFI_IA32" &&
  mkdir -p ${destination} &&
  # TFTP server points the client to start booting from /lpxelinux.0
  # pxelinux.0 requires file /ldlinux.c32
  # pxelinux.0 requires "configuration file": /pxelinux.cfg/default
  tar xvf ${current_directory}/${syslinux_folder}.tar.gz \
    -C ${destination} \
    --strip-components 3 ${syslinux_folder}/efi32/efi/syslinux.efi \
    &&
  tar xvf ${current_directory}/${syslinux_folder}.tar.gz \
    -C ${destination} \
    --strip-components 5 \
    ${syslinux_folder}/efi32/com32/elflink/ldlinux/ldlinux.e32 \
    &&
  true
} && EFI_IA32__clients &&
# ============================================================================ #



# ============================================================================ #
function EFI_x86-64__clients()
{
  destination="${current_directory}/syslinux/EFI_x86-64" &&
  mkdir -p ${destination} &&
  # TFTP server points the client to start booting from /lpxelinux.0
  # pxelinux.0 requires file /ldlinux.c32
  # pxelinux.0 requires "configuration file": /pxelinux.cfg/default
  tar xvf ${current_directory}/${syslinux_folder}.tar.gz \
    -C ${destination} \
    --strip-components 3 ${syslinux_folder}/efi64/efi/syslinux.efi \
    &&
  tar xvf ${current_directory}/${syslinux_folder}.tar.gz \
    -C ${destination} \
    --strip-components 5 \
    ${syslinux_folder}/efi64/com32/elflink/ldlinux/ldlinux.e64 \
    &&
  true
} && EFI_x86-64__clients &&
# ============================================================================ #



# ============================================================================ #
function secure_boot__clients()
{
  destination="${current_directory}/secure_boot" &&
  mkdir -p ${destination} &&
  # Shim - signed boot loader, for secure booting
  mkdir ${destination}/tmp &&
  (
    cd ${destination}/tmp &&
    wget https://yum.oracle.com/repo/OracleLinux/OL9/baseos/latest/x86_64/getPackage/shim-x64-15.8-1.0.3.el9.x86_64.rpm &&
    rpm2cpio ./shim-x64-15.8-1.0.3.el9.x86_64.rpm | cpio -dimv &&
    mv ./boot/efi/EFI/redhat/shim.efi .. &&
    mv ./boot/efi/EFI/redhat/shimx64.efi .. &&
    # Then shim will load revocations.efi and grubx64.efi
    wget https://yum.oracle.com/repo/OracleLinux/OL9/baseos/latest/x86_64/getPackage/grub2-efi-x64-2.06-77.0.1.el9.x86_64.rpm &&
    rpm2cpio ./grub2-efi-x64-2.06-77.0.1.el9.x86_64.rpm | cpio -dimv &&
    mv ./boot/efi/EFI/redhat/grubx64.efi .. &&
    true
  ) &&
  rm -rf ${destination}/tmp &&
  chmod a+r ${destination}/*.efi &&
  true
} && secure_boot__clients &&
# ============================================================================ #

# rm -f ${current_directory}/${syslinux_folder}.tar.gz &&

set +x &&
exit 0
# ============================================================================ #

