## Azure Linux (previously CBL-Mariner)

https://github.com/microsoft/azurelinux

```sh
wsl.exe --system --user root
root@PAULW11 [ / ]# ls -la
total 2236
drwxr-xr-x   1 root root     200 Jul  2 08:53 .
drwxr-xr-x   1 root root     200 Jul  2 08:53 ..
-rwxr-xr-x   1 root root       0 Aug 14  2024 .dockerenv
-rw-r--r--   1 root root   10145 Jun 15  2024 EULA-Container.txt
lrwxrwxrwx   1 root root       7 Jan 23  2024 bin -> usr/bin
drwx------   2 root root    4096 Aug 14  2024 boot
drwxr-xr-x  16 root root    3560 Jul  2 08:53 dev
drwxr-xr-x   1 root root     200 Jul  3 14:19 etc
drwxr-xr-x   1 root root      60 Aug 14  2024 home
-rwxrwxrwx   1 root root 2260248 Nov  9  2024 init
lrwxrwxrwx   1 root root       7 Jan 23  2024 lib -> usr/lib
lrwxrwxrwx   1 root root       7 Jan 23  2024 lib64 -> usr/lib
drwx------   2 root root    4096 Jan  1  1970 lost+found
drwxr-xr-x   2 root root    4096 Jan 23  2024 media
drwxr-xr-x   1 root root     140 Jul  2 08:53 mnt
drwxr-xr-x   2 root root    4096 Jan 23  2024 opt
dr-xr-xr-x 328 root root       0 Jul  2 08:53 proc
drwxr-x---   1 root root      60 Jul  3 14:20 root
drwxr-xr-x   8 root root     160 Jul  2 08:53 run
lrwxrwxrwx   1 root root       8 Jan 23  2024 sbin -> usr/sbin
lrwxrwxrwx   1 root root       7 Jan 23  2024 srv -> var/srv
dr-xr-xr-x  11 root root       0 Jul  2 08:52 sys
drwxrwxrwt   1 root root     100 Jul  3 14:17 tmp
drwxr-xr-x   1 root root     100 Aug 14  2024 usr
drwxr-xr-x   1 root root      60 Jun 15  2024 var

root@PAULW11 [ / ]# cat /etc/os-release
NAME="Common Base Linux Mariner"
VERSION="2.0.20240609"
ID=mariner
VERSION_ID="2.0"
PRETTY_NAME="CBL-Mariner/Linux"
ANSI_COLOR="1;34"
HOME_URL="https://aka.ms/cbl-mariner"
BUG_REPORT_URL="https://aka.ms/cbl-mariner"
SUPPORT_URL="https://aka.ms/cbl-mariner"
```
