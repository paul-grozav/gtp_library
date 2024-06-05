# ============================================================================ #
# Authors:
# - Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# Runs as root
# ============================================================================ #
# Current directory, where the script exists
script_dir="$(cd $(dirname ${0}); pwd)" &&

# build
export DEBIAN_FRONTEND=noninteractive &&
apt-get update &&
test="" &&
# Only for debugging
test="procps less nano rsyslog tftp-hpa curl net-tools tcpdump" &&
apt-get install -y isc-dhcp-server tftpd-hpa nginx ${test} &&
apt clean &&

cp /mnt/get_binaries.sh /srv/tftp/ &&
(
  cd /srv/tftp &&
  bash get_binaries.sh &&
  wget http://tinycorelinux.net/15.x/x86/release/Core-current.iso \
    -O ./tiny_core_linux.iso &&
  cp -r /mnt/pxelinux.cfg /srv/tftp/ &&
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
rm -f /etc/dhcp/dhcpd.conf &&
cp /mnt/dhcpd.conf /etc/dhcp/dhcpd.conf &&
rm -f /var/run/dhcpd.pid &&

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

#/sbin/rsyslogd &&
#touch /var/log/syslog &&
/etc/init.d/isc-dhcp-server start &&
#/etc/init.d/isc-dhcp-server start ||
#  [ "$(ls -la /proc/*/exe | grep dhcpd | wc -l)" == "1" ] &&
/etc/init.d/tftpd-hpa start &&
/etc/init.d/nginx start &&
#tail -f /var/log/{syslog,nginx/*.log} &&
# sleep infinity &&


exit 0
# ============================================================================ #
