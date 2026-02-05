Using the Rook Ceph operator
https://rook.io/docs/rook/latest-release/Helm-Charts/operator-chart/
```yaml
repoURL: https://charts.rook.io/release
chart: rook-ceph
```
But see Ceph documentation as well:
https://docs.ceph.com/en/latest/man/8/ceph-osd/

You can also apply:
https://github.com/rook/rook/blob/master/deploy/examples/toolbox.yaml
which will help with running the `ceph` CLI manager.

## Technical setup
Then create a `CephCluster` object based on their [example](
  https://github.com/rook/rook/blob/release-1.18/deploy/examples/cluster.yaml).
Note that you may want to change the `.spec.storage.nodes[]` and add your nodes
with the disks they contribute. A node entry would be similar to:
```yaml
- name: oc1
  devices:
  - name: /dev/disk/by-id/ata-WDC_WD30EFRX-68EUZN0_WD-WCC4NPUZ4ZFR
```
Unlike Longhorn for example, you will see that rook-ceph is not creating a
`StorageClass` by default, you have to do more of the low-level manual work
yourself.

First you will need to create a `Pool`, before you can actually make a
`StorageClass`.
```yaml
apiVersion: ceph.rook.io/v1
kind: CephBlockPool
metadata:
  name: replica-pool
  namespace: ceph
spec:
  # This ensures data is spread across different nodes
  failureDomain: host
  replicated:
    size: 3
```
You will see that this `Pool` object, creates more PGs.

Next you will need to create an SC (`StorageClass`), before you can actually
make PVCs.

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: rook-ceph-block
  namespace: ceph
# Note that the namespace where rook-ceph was installed is the prefix in the
# next provisioner
provisioner: ceph.rbd.csi.ceph.com
parameters:
  # ClusterID must match the namespace name where your CephCluster is defined
  clusterID: ceph
  # Must match the pool name above
  pool: replica-pool
  imageFormat: "2"
  imageFeatures: layering

  # These secrets are created by the Rook operator automatically
  # The following namespaces must match the namespace name where your
  # CephCluster is defined
  csi.storage.k8s.io/provisioner-secret-name: rook-csi-rbd-provisioner
  csi.storage.k8s.io/provisioner-secret-namespace: ceph
  csi.storage.k8s.io/controller-expand-secret-name: rook-csi-rbd-provisioner
  csi.storage.k8s.io/controller-expand-secret-namespace: ceph
  csi.storage.k8s.io/node-stage-secret-name: rook-csi-rbd-node
  csi.storage.k8s.io/node-stage-secret-namespace: ceph

reclaimPolicy: Delete
allowVolumeExpansion: true
```

Now you can create the PVC (`PersistentVolumeClaim`):
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ceph-sample-pvc
  namespace: ceph
spec:
  storageClassName: rook-ceph-block
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

If your controller plugin pods are fine, you should now see the PV
(`PersistentVolume`) created by the provisioner, based on your PVC.

You can even mount the PV into a pod like:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ceph-pod
  namespace: ceph
spec:
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: ceph-sample-pvc
  containers:
  - name: test
    image: ghcr.io/linuxcontainers/alpine:latest
    command:
    - sleep
    - infinity
    volumeMounts:
    - name: data
      mountPath: /mnt
```
Then if you exec into the pod you can see the PV as `/dev/rbd0`:
```sh
/ # df -h /mnt
Filesystem                Size      Used Available Use% Mounted on
/dev/rbd0                 4.8G     24.0K      4.8G   0% /mnt
/ # cd /mnt
/mnt # ls -la
total 28
drwxr-xr-x    3 root     root          4096 Jan 29 10:09 .
drwxr-xr-x    1 root     root          4096 Jan 29 10:14 ..
drwx------    2 root     root         16384 Jan 29 10:09 lost+found
/mnt #
```

## Terminology

#### OSD
The OSD ( Object Storage Daemon ) manages data on local storage with redundancy
and provides access to that data over the network.

Preparing the disks for Ceph. The osd-prepare job/pod will need the disk to have
no partition and no filesystem on it: `sudo wipefs --all /dev/disk/by-id/XYZ`.

Once the drives are prepared, you can invoke a new OSD-prepare job/pod by:
```sh
kubectl -n ceph rollout restart deployment rook-ceph-operator
```

#### Pool, PG and Object
A `Pool` in Ceph is a logical partition for storing objects. If you think of
Ceph as a giant hard drive, a pool is like a partition on that drive. The Ceph
administrator creates, names, and manages pools.

The `PG` ( `Placement Group` ) is a logical sharding mechanism used to group
thousands (or millions) of objects together for easier management. The PG is a
subset (a part) of the Pool. The PG handles "where" the data goes, on the
physical disks. Ceph subdivides every pool into a specific number of PGs (e.g.,
32, 64, or 128) and names and manages them automatically.

The `Object` is the data, the actual file you store. Every object belongs to
exactly one PG, and every PG belongs to exactly one Pool.

Analogies:
1. While you could say that the Objects are like files, PGs like folders and
pools like partitions, that would be fair for Objects and Pools, but PGs are not
exactly like folders.
2. A pool is more like a Warehouse that defines security and temperature for
the boxes being stored. And a PG is more like a Shipping Pallet, that groups
boxes together for moving.

If you look at your PG IDs (like 1.0 or 1.a4), the number before the dot is the
Pool ID.
- PG `1.0` is Placement Group #`0` inside Pool #`1`.
- PG `2.15` is Placement Group #`15` inside Pool #`2`.

The Lifecycle: From Object to Disk
```txt
File/Object: You upload cat.jpg.

Pool: You put it in the photos pool (which is set to size 3).

PG: Ceph hashes the name cat.jpg and places it into PG 1.a4.

OSD: Because the photos pool has a CRUSH rule to replicate data 3 times, PG 1.a4
is sent to 3 different physical disks (OSDs).
```

#### Controller Plugin
The `Controller Plugin` is a "provisioner", it is the brain that talks to K8s
API to create the volumes). You can see these pods by filtering for
`ctrlplugin`, one such example being:
`ceph.cephfs.csi.ceph.com-ctrlplugin-84b9cffc86rf6jv`.


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
