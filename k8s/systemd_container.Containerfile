# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# podman build --tag ol10img -f Containerfile .
# podman run -it --rm --name ol10ctr ol10img
from container-registry.oracle.com/os/oraclelinux:10

# Set root password
run echo "root:theWordYouNeedToPass" | chpasswd

# Enable systemd as PID 1
stopsignal SIGRTMIN+3
cmd ["/sbin/init"]
# ============================================================================ #
