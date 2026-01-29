Using the Rook Ceph operator https://rook.io/docs/rook/latest-release/Helm-Charts/operator-chart/
```yaml
repoURL: https://charts.rook.io/release
chart: rook-ceph
```
But see Ceph documentation as well: https://docs.ceph.com/en/latest/man/8/ceph-osd/

You can also apply:
https://github.com/rook/rook/blob/master/deploy/examples/toolbox.yaml
which will help with running the `ceph` CLI manager.

## Terminology

#### OSD
The OSD ( Object Storage Daemon ) manages data on local storage with redundancy and provides access to that data over the network.

Preparing the disks for Ceph. The osd-prepare job/pod will need the disk to have
no partition and no filesystem on it: `sudo wipefs --all /dev/disk/by-id/XYZ`.

Once the drives are prepared, you can invoke a new OSD-prepare job/pod by:
```sh
kubectl -n ceph rollout restart deployment rook-ceph-operator
```

## CLI
```sh
$ kubectl -n ceph exec deploy/rook-ceph-tools -- ceph status
  cluster:
    id:     afcdc5e5-b325-41b8-9cc9-11690df41a7d
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum b,c,d (age 25h)
    mgr: a(active, since 12h), standbys: b
    osd: 1 osds: 1 up (since 25h), 1 in (since 39h)

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   27 MiB used, 545 GiB / 545 GiB avail
    pgs:
```
Going further I'll focus on the `ceph` command itself, skipping the kubectl
prefix. Or you can just run them in this interactive session:
`kubectl -n ceph exec -it deploy/rook-ceph-tools -- bash`

```sh
$ ceph osd out 0
marked out osd.0.
$ ceph osd set noup # Disable auto-up
noup is set
$ ceph osd down 0
marked down osd.0.
$ ceph osd purge 0 --yes-i-really-mean-it
purged osd.0
$ ceph osd unset noup
noup is unset

# Ack notifications:
$ ceph crash archive-all
```
