Enable `Secure Boot` in the UEFI firmware setup. For example by going to:
`Security -> Secure Boot -> Secure Boot  [Enabled]`
```sh

  /---------- Secure Boot Violation ----------\
  |                                           |
  | Invalid signature detected. Check Secure  |
  |           Boot Policy in Setup            |
  |                                           |
  |-------------------------------------------|
  |                    Ok                     |
  \-------------------------------------------/

```
#### ISO bootloader
Then you can download [OracleLinux-R10-U0-x86_64-boot-uek.iso](
https://yum.oracle.com/ISOS/OracleLinux/OL10/u0/x86_64/OracleLinux-R10-U0-x86_64-boot-uek.iso)
and extract the `EFI` folder from the .iso :
```sh
$ find EFI
EFI/
EFI/BOOT
EFI/BOOT/BOOTX64.EFI
EFI/BOOT/fonts
EFI/BOOT/fonts/unicode.pf2
EFI/BOOT/grub.cfg
EFI/BOOT/grubx64.efi
EFI/BOOT/mmx64.efi
```
Place these in your TFTP public folder, and configure the DHCP to instruct your
machine to boot the `EFI/BOOT/grubx64.efi` file. But this fails with an invalid
signature.

#### shim package
```sh
$ podman run -it --rm container-registry.oracle.com/os/oraclelinux:10
bash-5.2# dnf install grub2-efi-x64 shim-x64
bash-5.2# ls -la /boot/efi/EFI/redhat/
total 7632
drwx------ 2 root root    4096 Nov 12 12:01 .
drwx------ 4 root root    4096 Nov 12 11:58 ..
-rwx------ 1 root root     134 Jun  4 00:00 BOOTX64.CSV
-rwx------ 1 root root 4034768 Sep 18 00:00 grubx64.efi
-rwx------ 1 root root  863304 Jun  4 00:00 mmx64.efi
-rwx------ 1 root root  965024 Jun  4 00:00 shim.efi
-rwx------ 1 root root  965672 Jun  4 00:00 shimx64-oracle.efi
-rwx------ 1 root root  965024 Jun  4 00:00 shimx64.efi
```
Place `shimx64.efi` and `grubx64.efi` in the root of your TFTP folder and point
your DHCP machine config to boot `shimx64.efi`:

```txt
>>Checking Media Presence......
>>Media Present......
>>Start PXE over IPv4 on MAC: A1-B2-C3-D4-E5-F6.
  Station IP address is ...10.89.85.31

  Server IP address is ...10.89.85.5
  NBP filename is shimx64.efi
  NBP filesize is 965024 Bytes

>>Checking Media Presence......
>>Media Present......
 Downloading NBP file...

  NBP file downloaded successfully.
Fetching Netboot Image revocations.efi
Unable to fetch TFTP image: TFTP Error
Fetching Netboot Image grubx64.efi
grub>
```
It will drop to a shell because no grub config file was found for example at:
`EFI/redhat/grub.cfg-01-a1-b2-c3-d4-e5-f6`. You could add this config in it:
```txt
set default="1"
set timeout=60
#search --no-floppy --set=root -l 'OL-10-0-0-BaseOS-x86_64'
menuentry 'Paul Aleph Oracle Linux 10.0.0' --class fedora --class gnu-linux --class gnu --class os {
  linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=OL-10-0-0-BaseOS-x86_64 rd.live.check quiet
  initrdefi /images/pxeboot/initrd.img
}
```

#### UEFI Secure Network booting
```sh
# UEFI Secure network boot
qemu-system-x86_64 -device virtio-net-pci,netdev=net0 -netdev user,id=net0,net=192.168.88.0/24,tftp=/root/redhat,bootfile=/shimx64.efi -drive if=pflash,format=raw,unit=0,file=/usr/share/OVMF/OVMF_CODE_4M.ms.fd,readonly=on -drive if=pflash,format=raw,unit=1,file=${HOME}/OVMF_VARS_4M.ms.fd -m 2G -cpu Broadwell -boot n -M q35 -serial stdio -display none -machine graphics=off
``` 
But note that the pre-signed grub build is not built with `./configure --with-gnutls` and thus has no TLS support, which means you can't load the kernel from an HTTPS server.

#### Building your GRUB

##### Building GRUB
```sh
# podman run -it --rm ubuntu:24.04
apt-get install -y \
  git \
  curl \
  autoconf \
  gettext \
  wget \
  python3 \
  libtool \
  ` # ` \
  autoconf-archive \
  libpkgconf3 \
  pkg-config \
  pkgconf \
  pkgconf-bin \
  gawk \
  ` # ` \
  build-essential \
  autopoint \
  libbison-dev \
  flex \
  &&
update-alternatives --set awk /usr/bin/gawk &&
cd /root &&
if [ ! -d src ]
then
  git clone https://git.savannah.gnu.org/git/grub.git src
  # git checkout to certain branch/tag? (thinking)
fi &&

# 1. Convert your trusted CA certificate (e.g., in PEM format) to DER format first - can we integrate this CA into the grub build?
# curl -o ./trusted_ca.pem https://letsencrypt.org/certs/isrgrootx1.pem &&
# openssl x509 -in trusted_ca.pem -out trusted_ca.der -outform DER &&

# 2. Configure and build GRUB, linking the CA certificate
# install autopoint
cd src &&
bash bootstrap &&
bash autogen.sh &&
mkdir /root/install &&
time sh ./configure \
  MAWK=gawk \
  AWK=gawk \
  ` # disable PO translation` \
  --disable-nls \
  ` # This prefix defaults to / - this is where apps will be installed` \
  --prefix=/root/install \
  --target=x86_64 \
  --with-platform=efi \
  ` # This adds the TLS to HTTP = httpS ? ` \
  --with-gnutls \
  ` # --enable-grub-modules="net http https pki keychain" ` \
  ` # --enable-boot-time-module-config ` \
  ` # --with-grub-efi-certs=$(pwd)/../trusted_ca.der ` \
  &&

time make \
  MAWK=gawk \
  AWK=gawk \
  --jobs $(( $(nproc) - 1 )) \
  &&

#./grub-install \
#  --target=x86_64-efi \
#  --efi-directory=../install \
#  --bootloader-id=GRUB \
#  &&
# This DESTDIR path is relative to ./configure --prefix (chroot)
# DESTDIR defaults to /
make install &&

mkdir /root/build &&
/root/install/bin/grub-mkimage \
  --format=x86_64-efi \
  --prefix=/root/install \
  --output=/root/build/BOOTX64.EFI \
  ` # Modules ` \
  net http gcry_md5 gcry_sha256 gcry_rsa gcry_sha512 \
  &&
true
# Use the /root/build/BOOTX64.EFI
```

##### PK, KEK, DB/DBX, MOK
The UEFI stores it's settings in the NVRAM filesystem. In NVRAM we can find the:
- **PK (Platform Key)** - this is set by the computer manufacturer( HP, Dell,
Lenovo ) - this is the Root of Trust - this controls the authorization to update
the KEK.
- **KEK (Key Exchange Key)** - set by manufacturer but can be changed by system
owner, if in secure boot *Setup Mode* - this authorizes the updates to DB / DBX.
- **DB (DataBase) / DBX (Forbidden DataBase) of signatures** - this can be
changed by the system/platform owner in the UEFI setup utility. This controls
what binaries are allowed to run(like Linux kernels, BSD, Windows, shim, etc)
and the DBX controls the list of revoked or compromised binary executables. 

The [shim](https://github.com/rhboot/shim) is a binary that is already
pre-signed with Microsoft's certificate that is whitelisted in the DB of most
UEFI systems, thus allowing it to start when secure boot is enabled. It defines
and uses a new section in NVRAM, the **MOK (Machine Owner Key)**. The shim
allows the machine/system/platform owner to register a key/certificate in the
MOK, even during the runtime of Linux, using a command:
`mokutil --import my.crt` This command will place the new certificate in a
temporary location, and the next time the shim starts/runs, it will detect the
new certificate, and ask for [approval](
   https://commons.wikimedia.org/wiki/File:Shim_MokManager_screenshot.png)
before writing it to the actual MOK list. Also, before the shim starts your
kernel, it will check if the kernel is signed with one of the keys in the MOK
list. If the kernel is not signed by a MOK, then it will refuse to start it.

See also:
1. https://docs.oracle.com/en/operating-systems/oracle-linux/10/secure-boot/index.html
