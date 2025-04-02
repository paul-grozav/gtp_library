#!/bin/bash
# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# Start debugging
set -x &&

# Current directory, where the script exists
current_directory="$(cd $(dirname $0); pwd)" &&
project_root="$(git rev-parse --show-toplevel)" &&

project_name="$(basename ${project_root})"

#all_args=$@

# Example: bash ./ceph.sh --start_monitor
# ============================================================================ #
function start_monitor()
{
  version="v5.0.5-stable-5.0-octopus-centos-8-x86_64" &&

  docker stop -t0 ceph_mon ;
  # Generate persistent config files
  docker run -it --rm -v ${current_directory}/:/mnt --entrypoint /bin/bash \
    ceph/daemon:${version} \
    -c "cd /mnt && rm -rf fs" &&
#  rm -rf ${current_directory}/fs &&
  mkdir -p ${current_directory}/fs/{etc,var} &&
  docker run -d \
    --rm=true \
    --name ceph_mon \
    --net=host \
    -e MON_IP=192.168.0.7 \
    -e CEPH_PUBLIC_NETWORK=192.168.0.0/24 \
    ceph/daemon:${version} \
    mon \
  &&
  docker cp ceph_mon:/etc/ceph ${current_directory}/fs/etc/ceph &&
  docker stop -t0 ceph_mon &&

  docker run -d \
    --rm=true \
    --name ceph_mon \
    --net=host \
    -v ${current_directory}/fs/etc/ceph:/etc/ceph:z \
    -v ${current_directory}/fs/var/lib/ceph:/var/lib/ceph:z \
    -e MON_IP=192.168.0.7 \
    -e CEPH_PUBLIC_NETWORK=192.168.0.0/24 \
    ceph/daemon:${version} \
    mon \
  &&

  # docker exec -it ceph_mon ceph -s
  # docker exec -it ceph_mon ceph -w
  # docker exec -it ceph_mon ceph mon stat

  # dd if=/dev/zero of=$(pwd)/dev.2 bs=1M count=1024 &&
  # mknod $(pwd)/dev.2.nod b 7 200 &&
  # /sbin/losetup $(pwd)/dev.2.nod $(pwd)/dev.2 && # undo with "losetup -d /dev/loop200" AND list with: "losetup"
  # mkfs.ext4 ./dev.2.nod &&
  # mount dev.2.nod dev.2.dir
  # ceph-volume lvm prepare --data /dev/loop0


  # docker exec -it ceph_mon ceph osd create;
  docker exec -it ceph_mon bash -c "
    ceph osd create &&
    ceph auth get client.bootstrap-osd -o /var/lib/ceph/bootstrap-osd/ceph.keyring
  " &&
  docker stop -t0 ceph_osd ;

  docker run -it \
    --name ceph_osd \
    --net=host \
    --privileged=true \
    --pid=host \
    --ipc=host \
    --rm=true \
    -v ${current_directory}/fs/etc/ceph/:/etc/ceph/:z \
    -v ${current_directory}/fs/var/lib/ceph/:/var/lib/ceph/:z \
    -v /dev/:/dev/ \
    -v /run/lvm/:/run/lvm/ \
    -e OSD_DEVICE=/dev/loop0 \
    -e CEPH_DAEMON=OSD_CEPH_VOLUME_ACTIVATE \
    -e OSD_ID=0 \
    ceph/daemon:${version} \
  &&
#    osd_ceph_disk  \

  exit 0
}





# ============================================================================ #
# Print help
# ============================================================================ #
function print_help() {
  echo "--start_monitor   Increment build number and push"
  echo "--help            Print the help message"
}





# ============================================================================ #
# Case logic
# ============================================================================ #

# If no parameter
if [ ${#} == 0 ]; then
  print_help
fi

# Case
if [ ${1} ]; then
  case "${1}" in
    --start_monitor) start_monitor ; exit ${?} ;;
    --help) print_help ; exit ${?} ;;
    *) print_help ; exit ${?} ;;
    esac
fi

# Stop debugging
set +x &&

exit 0
# ============================================================================ #
