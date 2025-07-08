## Azure Linux (previously CBL-Mariner)

https://github.com/microsoft/azurelinux

[Download ISO](https://aka.ms/azurelinux-3.0-x86_64.iso)

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

# Installing packages using the Mariner package manager:
root@PAULW11 [ / ]# yum install less
Loaded plugin: tdnfrepogpgcheck
Refreshing metadata for: 'CBL-Mariner Official Extras 2.0 x86_64'
Refreshing metadata for: 'CBL-Mariner Official Microsoft 2.0 x86_64'
Refreshing metadata for: 'CBL-Mariner Official Base 2.0 x86_64'
mariner-official-base                  1740014 100%
Installing:
less      x86_64      590-4.cm2     mariner-official-base     309.82k    156.08k

Total installed size: 309.82k
Total download size: 156.08k
Is this ok [y/N]: y
less                                    159823 100%
Testing transaction
Running transaction
Installing/Updating: less-590-4.cm2.x86_64
root@PAULW11 [ / ]#
```

### WSL graphics
```sh
root@PAULW11 [ / ]# ps faux
root           9  0.0  0.0 122316  8700 ?        Sl   07:29   0:00 /usr/bin/WSLGd
wslg          13  0.6  0.3 810424 50592 ?        Sl   07:29   0:01  \_ /usr/bin/weston --backend=rdp-backend.so --modules=wslgd-notify.so --xwayland --socket=wayland-0 --shell=rdprail-shell.so --log=/mnt/wslg/weston.log --logger-scopes=log,rdp-backend,rdprail-shell
wslg         452  0.2  0.4 226900 74016 ?        Ssl  07:29   0:00  |   \_ /usr/bin/Xwayland :0 -rootless -core -listen 37 -wm 38 -terminate -nolisten local -ac
wslg        1317  0.0  0.0   2476  1872 ?        S    07:30   0:00  \_ /init /mnt/c/Program Files/WSL/msrdc.exe msrdc.exe /wslg /silent /v:58607574-843C-4F2D-BF3B-856B66F299FA /hvsocketserviceid:00000001-FACB-11E6-BD58-64006A7986D3 /plugin:WSLDVC_PACKAGE /wslgsharedmemorypath:WSL\58607574-843C-4F2D-BF3B-856B66F299FA\wslg C:\Program Files\WSL\wslg.rdp
wslg        1318  0.0  0.0   9616  4196 ?        S    07:30   0:00  \_ /usr/bin/dbus-daemon --syslog --nofork --nopidfile --system
wslg        1319  0.0  0.0 235336  8376 ?        Sl   07:30   0:00  \_ /usr/bin/pulseaudio --log-time=true --disallow-exit=true --exit-idle-time=-1 --load=module-rdp-sink sink_name=RDPSink --load=module-rdp-source source_name=RDPSource --load=module-native-protocol-unix socket=/mnt/wslg/PulseServer auth-anonymous=true --log-target=newfile:/mnt/wslg/pulseaudio.log

```
