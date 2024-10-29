# ============================================================================ #
# Authors:
# - Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# Runs as root
# using dnsmasq to support dhcp and tftp into one server.
# isc-dhcp-server seems to make the client send a proxyDHCP request, which that
# server implementation can not handle ...
# ============================================================================ #
# Current directory, where the script exists
script_dir="$(cd $(dirname ${0}); pwd)" &&

# Make this a GateWay and enable NAT:
# Enable forwarding on the box
echo 1 > /proc/sys/net/ipv4/ip_forward &&
# Assuming your public(internet/WAN) interface is eth0 and local(LAN) interface
# is eth1, do the following:
# Set natting the natting rule
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE &&
# Accept traffic from eth1
iptables -A INPUT -i eth1 -j ACCEPT &&
# Allow established connections from the public interface
iptables -A INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT &&
# Allow outgoing connections
iptables -A OUTPUT -j ACCEPT &&
# Note: these settings will be lost after reboot. Read how to persist iptables
# rules.

# to avoid client transfer problems:
#sysctl net.ipv4.tcp_wmem="4096 16384 3355232" &&
sysctl net.ipv4.tcp_wmem="4096 16384 32768" &&
sysctl net.ipv4.tcp_mem="4096 16384 32768" &&
sysctl net.ipv4.tcp_window_scaling=0 &&

# build
export DEBIAN_FRONTEND=noninteractive &&
apt-get update &&
test="" &&
# Only for debugging
test="procps less nano rsyslog tftp-hpa curl net-tools tcpdump nmap" &&
apt-get install -y dnsmasq isc-dhcp-server tftpd-hpa apache2 rpm2cpio ${test} &&
apt clean &&

# true ; exit 0 &&

cp /mnt/get_binaries.sh /srv/tftp/ &&
(
  cd /srv/tftp &&
  bash get_binaries.sh &&
  wget http://tinycorelinux.net/15.x/x86/release/Core-current.iso \
    -O ./tiny_core_linux.iso &&
  wget https://boot.ipxe.org/ipxe.efi &&
  wget https://boot.ipxe.org/ipxe.iso &&
  cp -r /mnt/pxelinux.cfg /srv/tftp/ &&
  cp -r /mnt/secure_boot /srv/tftp/ &&
  true
) &&
(
  cd /var/www/html &&
  cp /srv/tftp/tiny_core_linux.iso . &&
  cp /srv/tftp/syslinux/Intel_x86PC/memdisk . &&
  wget https://cdn.openbsd.org/pub/OpenBSD/7.6/i386/cd76.iso &&
  wget https://tancredi-paul-grozav.gitlab.io/aleph/distribution_content/aleph.krnl &&
  wget https://tancredi-paul-grozav.gitlab.io/aleph/distribution_content/aleph.ird &&
  wget https://tancredi-paul-grozav.gitlab.io/aleph/distribution_content/aleph.sfs &&
  cp -r /mnt/aleph_config . &&
  mkdir EFI_IA32 && cd EFI_IA32 &&
  wget https://ftp.debian.org/debian/dists/stable/main/installer-i386/current/images/hd-media/vmlinuz &&
  wget https://ftp.debian.org/debian/dists/stable/main/installer-i386/current/images/hd-media/initrd.gz &&
  cd .. &&
  true
) &&

set -x &&
#true ; exit 0 &&

# service configuration files
# isc-dhcp is more clear in it's definition, works best for beginners or small
# number of machines. dnsmasq is good at labeling and applying rules to many
# machines(though they say it was not designed to be very scalable, works fine
# for a relatively small number of machines). Also, note that ISC ended support
# for dhcp, and now they develop Kea as a DHCP replacement implementation.
(
  # Use isc-dhcp-server + tftpd-hpa
  # exit 0 &&
  # Only start ipv4 dhcpd - with our cfg file
  # logs to /var/log/syslog
  # ensure this interface name's assigned IP settings, match the CIDR defined
  # in dhcpd.conf
  echo "INTERFACESv4=\"eth1\"" > /etc/default/isc-dhcp-server &&
  #echo "INTERFACESv4=\"br0 eth0\"" > /etc/default/isc-dhcp-server &&
  rm -f /etc/dhcp/dhcpd.conf &&
  cp /mnt/dhcpd.conf /etc/dhcp/dhcpd.conf &&
  rm -f /var/run/dhcpd.pid &&

  # TFTP server dir mapped to hypervisor
  # logs to /var/log/syslog
  sed 's/^TFTP_OPTIONS="--secure"$/TFTP_OPTIONS="--secure -v -v -v"/g' \
    -i /etc/default/tftpd-hpa &&
  true
) &&
(
  # Use dnsmasq for both DHCP and TFTP
  exit 0 &&
  cp /mnt/custom_dnsmasq.conf /etc/dnsmasq.d/ &&
  true
) &&

# HTTP server
# logs to /var/log/nginx/*.log
#rm -rf /var/www/html &&
#ln -s /data/http /var/www/html &&

#systemctl disable isc-dhcp-server &&
#systemctl disable tftpd-hpa &&



# start services
# Required for isc-dhcp-server and tftpd-hpa
/sbin/rsyslogd &&
touch /var/log/syslog &&
#/etc/init.d/nginx start &&
/etc/init.d/apache2 start &&
#tail -f /var/log/{syslog,nginx/*.log} &&

(
  # Use isc-dhcp-server + tftpd-hpa
  /etc/init.d/isc-dhcp-server start &&
  #/etc/init.d/isc-dhcp-server start ||
  #  [ "$(ls -la /proc/*/exe | grep dhcpd | wc -l)" == "1" ] &&
  /etc/init.d/tftpd-hpa start &&
  true
) &&
(
  # Use dnsmasq for both DHCP and TFTP
  exit 0 &&
  /etc/init.d/dnsmasq start &&
  true
) &&
# sleep infinity &&

# Test servers:
# sudo nmap -e eth1 --script broadcast-dhcp-discover --script-args \
#   broadcast-dhcp-discover.mac=08:00:27:00:00:03,\
# broadcast-dhcp-discover.timeout=1s
# Maybe even tcpdump while dhcp-discover(to see more response details):
# tcpdump -i eth1 -n -vvv
# tftp 127.0.0.1 -m binary -c get syslinux/Intel_x86PC/lpxelinux.0
# curl -vvv http:/127.0.0.1:80/tiny_core_linux.iso | head

exit 0
# ============================================================================ #
