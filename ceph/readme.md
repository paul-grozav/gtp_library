1. Ceph **monitor** - maintain maps needed for Ceph daemons to coordinate with each other.
2. Ceph **manager** - keeps track of strage usage, system load, exports metrics...
3. Ceph **O**bject **S**torage **D**aemon - stores data, does: replication, recovery, rebalancing
4. Ceph **m**eta**d**ata **s**erver - stores metadata of Ceph FileSystem - allows POSIX FileSystem interface.

```sh
# Create container with no mounts, docker cp /etc/ceph/* from it to a tmp folder
# then move copied content to ./fs/etc/ceph and start another container mounting that
# Mon
docker run -it \
--name ceph_mon \
--net=host \
-v $(pwd)/fs/etc/ceph:/etc/ceph \
-v $(pwd)/fs/var/lib/ceph/:/var/lib/ceph \
-e MON_IP=192.168.0.7 \
-e CEPH_PUBLIC_NETWORK=192.168.0.0/24 \
ceph/daemon mon

ceph>docker exec -it ceph_mon ceph -s
ceph>docker exec -it ceph_mon ceph mon stat
ceph>docker exec -it ceph_mon ceph -w

# =====

ceph>fallocate -l 1GiB ./1.hdd
ceph>/sbin/mkfs.ext4 -j ./1.hdd
ceph>mkdir mnt
ceph>mount ./1.hdd ./mnt/
mount: only root can do that
ceph>su
Password: 
root@tedi:/home/tedi/docker_mnt/research/ceph# mount ./1.hdd ./mnt/
root@tedi:/home/tedi/docker_mnt/research/ceph# df -h
/dev/loop0                    976M  2.6M  907M   1% /data/research/ceph/mnt
ceph>docker exec -it ceph_mon ceph osd create

# OSD
docker run -it --net=host \
--name ceph_osd \
--pid=host \
--privileged=true \
-v $(pwd)/fs/etc/ceph:/etc/ceph \
-v $(pwd)/fs/var/lib/ceph/:/var/lib/ceph/ \
-v $(pwd)/mnt/:/var/lib/ceph/osd/ceph-1 \
-e OSD_TYPE=directory \
ceph/daemon osd
```
