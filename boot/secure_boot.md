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
machine to boot the `EFI/BOOT/grubx64.efi` file.

See also:
1. https://docs.oracle.com/en/operating-systems/oracle-linux/10/secure-boot/index.html