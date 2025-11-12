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

See also:
1. https://docs.oracle.com/en/operating-systems/oracle-linux/10/secure-boot/index.html
