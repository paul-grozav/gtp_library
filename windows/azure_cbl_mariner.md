## Azure Linux (previously CBL-Mariner)

https://github.com/microsoft/azurelinux

[Download ISO](https://aka.ms/azurelinux-3.0-x86_64.iso)

### 9P
Azure Linux (previously known as Common Base Linux (CBL) Mariner) uses the [9p
](https://en.wikipedia.org/wiki/9P_(protocol)) Plan 9 Filesystem Protocol,
developed by [Bell Labs](https://en.wikipedia.org/wiki/Bell_Labs) for their
[Plan 9](https://en.wikipedia.org/wiki/Plan_9_from_Bell_Labs) Operating System.
Azure Linux uses this protocol (filesystem type) to offer access to the Windows
partitions.
```sh
root@PAULW11 [ / ]#  mount | grep -w 9p
drivers on /usr/lib/wsl/drivers type 9p (ro,nosuid,nodev,noatime,dirsync,aname=drivers;fmask=222;dmask=222,mmap,access=client,msize=65536,trans=fd,rfd=7,wfd=7)
C:\ on /mnt/c type 9p (rw,noatime,dirsync,aname=drvfs;path=C:\;uid=1000;gid=1000;symlinkroot=/mnt/,mmap,access=client,msize=65536,trans=fd,rfd=5,wfd=5)
D:\ on /mnt/d type 9p (rw,noatime,dirsync,aname=drvfs;path=D:\;uid=1000;gid=1000;symlinkroot=/mnt/,mmap,access=client,msize=65536,trans=fd,rfd=5,wfd=5)
```

### WSL

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

# After a fresh WSL start
root           9  0.0  0.0 122316  8692 ?        Sl   07:28   0:00 /usr/bin/WSLGd
wslg          13  0.7  0.3 810424 50504 ?        Sl   07:28   0:01  \_ /usr/bin/weston --backend=rdp-backend.so --modules=wslgd-notify.so --xwayland --socket=wayland-0 --shell=rdprail-shell.so --log=/mnt/wslg/weston.log --logger-scopes=log,rdp-backend,rdprail-shell
wslg         441  0.2  0.4 226900 73344 ?        Ssl  07:28   0:00  |   \_ /usr/bin/Xwayland :0 -rootless -core -listen 37 -wm 38 -terminate -nolisten local -ac
wslg        1281  0.0  0.0   2476  1872 ?        S    07:28   0:00  \_ /init /mnt/c/Program Files/WSL/msrdc.exe msrdc.exe /wslg /silent /v:A18FC473-E2F1-4F84-A4D6-BBB23AECADD1 /hvsocketserviceid:00000001-FACB-11E6-BD58-64006A7986D3 /plugin:WSLDVC_PACKAGE /wslgsharedmemorypath:WSL\A18FC473-E2F1-4F84-A4D6-BBB23AECADD1\wslg C:\Program Files\WSL\wslg.rdp
wslg        1282  0.0  0.0   9616  4108 ?        S    07:28   0:00  \_ /usr/bin/dbus-daemon --syslog --nofork --nopidfile --system
wslg        1283  0.0  0.0 235336 10392 ?        Sl   07:28   0:00  \_ /usr/bin/pulseaudio --log-time=true --disallow-exit=true --exit-idle-time=-1 --load=module-rdp-sink sink_name=RDPSink --load=module-rdp-source source_name=RDPSource --load=module-native-protocol-unix socket=/mnt/wslg/PulseServer auth-anonymous=true --log-target=newfile:/mnt/wslg/pulseaudio.log

# When windows disappeared
root           9  0.0  0.0 122316  2164 ?        Sl   Jul08   0:00 /usr/bin/WSLGd
wslg        1318  0.0  0.0   9616  1660 ?        S    Jul08   0:00  \_ /usr/bin/dbus-daemon --syslog --nofork --nopidfile --system
wslg        1319  0.0  0.0 235440  4564 ?        Sl   Jul08   0:02  \_ /usr/bin/pulseaudio --log-time=true --disallow-exit=true --exit-idle-time=-1 --load=module-rdp-sink sink_name=RDPSink --load=module-rdp-source source_name=RDPSource --load=module-native-protocol-unix socket=/mnt/wslg/PulseServer auth-anonymous=true --log-target=newfile:/mnt/wslg/pulseaudio.log
wslg     1287219  0.0  0.3 749936 54120 ?        Sl   06:28   0:00  \_ /usr/bin/weston --backend=rdp-backend.so --modules=wslgd-notify.so --xwayland --socket=wayland-0 --shell=rdprail-shell.so --log=/mnt/wslg/weston.log --logger-scopes=log,rdp-backend,rdprail-shell
wslg     1287342  0.0  0.4 227712 74984 ?        Ssl  06:28   0:01  |   \_ /usr/bin/Xwayland :0 -rootless -core -listen 46 -wm 47 -terminate -nolisten local -ac
wslg     1288360  0.0  0.0  18524  8332 ?        Ss   06:29   0:00  |   \_ /usr/libexec/weston-rdprail-shell
wslg     1287356  0.0  0.0   2480  1876 ?        S    06:28   0:00  \_ /init /mnt/c/Program Files/WSL/msrdc.exe msrdc.exe /wslg /silent /v:58607574-843C-4F2D-BF3B-856B66F299FA /hvsocketserviceid:00000001-FACB-11E6-BD58-64006A7986D3 /plugin:WSLDVC_PACKAGE /wslgsharedmemorypath:WSL\58607574-843C-4F2D-BF3B-856B66F299FA\wslg C:\Program Files\WSL\wslg.rdp

# The wslgsharedmemorypath changes on WSL restarts/reboots
# The hvsocketserviceid does not change on WSL restarts (with no Windows restart)
```
The WSLg system is made of the weston display server(a Wayland compositor), and
`MSRDC.exe`, the MicroSoft Remote Desktop Client, which is a process that
connects to weston, over RDP(Remote Desktop Protocol), to fetch the video buffer
and display it in the Windows operating system, as one or multiple windows, that
are seamlessly integrating with the other Windows windows, basically offering
both Linux and Windows windows on the same taskbar.

There is one msrdc client for each WSL distribution(VM) that you run. Each VM
runs it's own CBL and WSLGd(with weston). That one msrdc process, opens multiple
windows.

There is a known problem that, WSLg windows are disappearing or freezing,
because the msrdc talks to weston over a TCP connection. And when that
connection is lost, the windows either go away(while GUI apps are still running
and sending their video output to weston, but no client is reading/rendering it)
, or the windows just freeze. This is known to happen when Windows goes to sleep
or hibernates, when you change network settings(enable/disable connection,
plug/unplug ethernet cables), or when you plug/unplug external monitors.
There are numerous issues open on this, this being one of them:
https://github.com/microsoft/wslg/issues/1098 , but apparently Microsoft has not
prioritized the fix for this in the past ~5 years or so.
