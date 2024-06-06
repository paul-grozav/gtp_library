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

# client transfer problems:
#sysctl net.ipv4.tcp_wmem="4096 16384 3355232" &&
sysctl net.ipv4.tcp_wmem="4096 16384 32768" &&
sysctl net.ipv4.tcp_mem="4096 16384 32768" &&
sysctl net.ipv4.tcp_window_scaling=0 &&

# build
export DEBIAN_FRONTEND=noninteractive &&
apt-get update &&
test="" &&
# Only for debugging
test="procps less nano rsyslog tftp-hpa curl net-tools tcpdump" &&
apt-get install -y dnsmasq tftpd-hpa apache2 rpm2cpio ${test} &&
apt clean &&

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
  cp /srv/tftp/pxe_syslinux/memdisk . &&
  wget https://tancredi-paul-grozav.gitlab.io/aleph/distribution_content/aleph.krnl &&
  wget https://tancredi-paul-grozav.gitlab.io/aleph/distribution_content/aleph.ird &&
  wget https://tancredi-paul-grozav.gitlab.io/aleph/distribution_content/aleph.sfs &&
  cp -r /mnt/aleph_config . &&
  true
) &&

# start
set -x &&
#true ; exit 0 &&
# Only start ipv4 dhcpd - with our cfg file
# logs to /var/log/syslog
# ensure this interface name's assigned IP settings, match the CIDR defined
# in dhcpd.conf
echo "INTERFACESv4=\"eth1\"" > /etc/default/isc-dhcp-server &&
#echo "INTERFACESv4=\"br0 eth0\"" > /etc/default/isc-dhcp-server &&
#rm -f /etc/dhcp/dhcpd.conf &&
#cp /mnt/dhcpd.conf /etc/dhcp/dhcpd.conf &&
#rm -f /var/run/dhcpd.pid &&
cp /mnt/custom_dnsmasq.conf /etc/dnsmasq.d/ &&

# TFTP server dir mapped to hypervisor
# logs to /var/log/syslog
#sed 's/^TFTP_OPTIONS="--secure"$/TFTP_OPTIONS="--secure -v -v -v"/g' \
#  -i /etc/default/tftpd-hpa &&
#rm -Rf /srv/tftp &&
#ln -s /data/tftp /srv/tftp &&

# HTTP server
# logs to /var/log/nginx/*.log
#rm -rf /var/www/html &&
#ln -s /data/http /var/www/html &&

systemctl disable isc-dhcp-server &&
systemctl disable tftpd-hpa &&

#/sbin/rsyslogd &&
#touch /var/log/syslog &&
/etc/init.d/dnsmasq start &&
#/etc/init.d/isc-dhcp-server start &&
#/etc/init.d/isc-dhcp-server start ||
#  [ "$(ls -la /proc/*/exe | grep dhcpd | wc -l)" == "1" ] &&
#/etc/init.d/tftpd-hpa start &&
#/etc/init.d/nginx start &&
/etc/init.d/apache2 start &&
#tail -f /var/log/{syslog,nginx/*.log} &&
# sleep infinity &&


exit 0
# ============================================================================ #
