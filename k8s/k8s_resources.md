# Resources in K8s

Read more here:
1. https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources

## RAM
### RAM formula
```txt
total_capacity =   system_reserved
                 + kube_reserved
                 + hard_eviction_threshold
                 + allocatable
```
##### RAM `total_capcity`
The total capacity is read from the system, say from `free -m`. This is the full
amount of RAM available to the Operating System.

##### RAM `system_reserved`
This is the amount of RAM allocated for the Operating System and any other
daemons and processes that are running outside of K8s. Usually a minimal OS
should be able to keep it's RAM usage in ~1GiB of RAM. This is configurable in
[KubeletConfiguration](
  https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/#kubelet-config-k8s-io-v1beta1-KubeletConfiguration)
in the field `.systemReserved.memory`.

##### RAM `kube_reserved`
This is the amount of RAM allocated for the Kubernetes system components, like
kubelet, kube-scheduler, kube API server, etc. This is configurable in
[KubeletConfiguration](
  https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/#kubelet-config-k8s-io-v1beta1-KubeletConfiguration)
in the field `.kubeReserved.memory`.

##### RAM `hard_eviction_threshold`
When the amount of free RAM on the OS drops below this threshold, then the hard
eviction is triggered (killing K8s pods to free resources). This is configurable
in [KubeletConfiguration](
  https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/#kubelet-config-k8s-io-v1beta1-KubeletConfiguration)
in the field `.evictionHard.memory.available`. To explicitly disable, pass a 0%
or 100% threshold on this resource. Note that eviction is looking at the actual
free RAM usage available on the Operating System, to see if it drops below this
threshold.

##### RAM `allocatable`
So, the allocatable space is actually calculated by the scheduler by subtracting
the `system_reserved`, `kube_reserved` and `hard_eviction_threshold` from the
`total_capcity`.

#### RAM example
For example, if you have a node with 12 GiB of RAM. You can allocate 2 GiB for
the OS, 1 GiB for Kube, and set the hard eviction at 1 GiB. This gives you an
allocatable space of 8 GiB (12-2-1-1). This 8 GiB can be used by K8s pods, as
they wish, and the scheduler will keep track of it's usage.

So you can have 8 GiB used by the pods, 2 GiB used by OS+system processes and
have Kube system processes that uses 1 GiB of RAM, and still be good. Until the
next malloc call which will start eating the last 1 GiB of RAM, and will trigger
the K8s hard eviction, killing pods to free some of the 8 GiB of allocatable
memory.

If however, the 2 GiB of the RAM that is reserved for the system, is not used
fully, but only 1/2 GiBs is used, then the eviction will not be triggered
because it still sees 2 GiB of free RAM (the 1 GiB allocated for eviction and
the 1 GiB of unsed system-reserved RAM).

#### RAM eviction
When the Kubelet starts evicting for the RAM resource, the "punishment" is
"hard", killing the pods/processes. Unlike the CPU resource for example, for
which the punishment is "soft", just throttling the performance of those
processes.

## CPU (logical)
CPU works just like RAM, with some exceptions.

K8s works with logical CPU cores. So if your system has 8 cores, and 2 threads
per core, you will see that `nproc` returns a number of 16 logical cores.







### CPU formula
```txt
total_capacity =   system_reserved
                 + kube_reserved
                 + allocatable
```
##### CPU `total_capcity`
The total capacity is read from the system, say from `nproc`. This is the full
amount of logical CPU cores available to the Operating System.

##### CPU `system_reserved`
This is the amount of logical CPU cores allocated for the Operating System and
any other daemons and processes that are running outside of K8s. Usually a
minimal OS should be able to keep it's CPU usage in 0.5 or 1 CPU Core. This is
configurable in [KubeletConfiguration](
  https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/#kubelet-config-k8s-io-v1beta1-KubeletConfiguration)
in the field `.systemReserved.cpu`.

##### CPU `kube_reserved`
This is the amount of logical CPU cores allocated for the Kubernetes system
components, like kubelet, kube-scheduler, kube API server, etc. This is
configurable in [KubeletConfiguration](
  https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/#kubelet-config-k8s-io-v1beta1-KubeletConfiguration)
in the field `.kubeReserved.cpu`.

##### CPU `allocatable`
So, the allocatable space is actually calculated by the scheduler by subtracting
the `system_reserved` and `kube_reserved` from the `total_capcity`.

#### CPU example
For example, if you have a node with 12 logical CPU cores. You can allocate 2
cores for the OS, 1 core for Kube, and set the hard eviction at 1 core. This
gives you an allocatable space of 8 cores (12-2-1-1). These 8 cores can be used
by K8s pods, as they wish, and the scheduler will keep track of it's usage.

So you can have 8 cores used by the pods, 2 cores used by OS+system processes
and have Kube system processes that uses 1 CPU core, and still be good.

If your OS only uses 1 out of the 2 reserved CPU cores, and your K8s pods needs
more CPU, they are allowed to borrow the free CPU from the system, however, when
the system processes need it, the OS will have a higher priority, throttling the
pod's CPU usage. In other words, if all processes on the node consume as much
CPU as they can, pods together cannot consume more than 8 CPUs.

#### CPU has no eviction
When eviction kicks in for the RAM resource, the "punishment" is "hard",
killing the pods/processes. However the CPU is a "compressible" resource. So the
punishment is "soft", just throttling the performance of those processes that
compete for the resources. In fact Kubelet will not even start evicting if the
cpu usage is "too high".







# Disk space
## Types of disk storage

```txt
/ (Total Disk Capacity)
│
├── [nodefs] - Managed by Kubelet
│   ├── /var/lib/kubelet
│   │   ├── pods/
│   │   │   └── {pod-uid}/
│   │   │       ├── volumes/
│   │   │       │   ├── kubernetes.io~empty-dir/  <-- [Ephemeral Storage]
│   │   │       │   ├── kubernetes.io~secret/     <-- (Projected RAM-disk)
│   │   │       │   └── kubernetes.io~configmap/
│   │   │       └── etc-hosts
│   │   ├── device-plugins/ (Sockets for GPUs, etc.)
│   │   └── plugins_registry/ (CSI Driver sockets)
│   └── /var/log/pods/ (Container stdout/stderr logs) <-- [Ephemeral Storage]
│
├── [imagefs] - Managed by Container Runtime (Containerd)
│   ├── /var/lib/containerd (or /var/lib/docker)
│   │   ├── io.containerd.content.v1/ (The raw "blobs" of images)
│   │   ├── io.containerd.snapshotter.v1/ (Unpacked layers)
│   │   └── overlays/ (The "Writable Layer" of the container) <-- [Ephemeral Storage]
│
└── [Persistent Storage] - Managed by CSI
    └── /mnt/disks/external-ssd/ (Mounted into pod via PersistentVolume)
```

Or simpler:
| Content                     | Where it lives              | Which "FS" is it billed to? |
|-----------------------------|-----------------------------|-----------------------------|
| Image Layers                | /var/lib/containerd/...     | imagefs                     |
| Container Writable Layer    | /var/lib/containerd/...     | imagefs                     |
| Container Logs              | /var/log/pods/...           | nodefs                      |
| emptyDir Volumes            | /var/lib/kubelet/...        | nodefs                      |

There are 2 types of storage `nodefs` and `imagefs` as described below.

It is a good practice to keep  the kubelet and the CR (Container Runtime)
directories on different filesystems / partitions. However for simplicity in the
past multiple cloud providers placed them on the same partition.


### 1. nodefs - Kubelet dir

This kubelet parameter defaults to: `--root-dir /var/lib/kubelet`

The Kubelet directory contains:
1. The emptyDir volumes - Stored in `/var/lib/kubelet/pods/{uid}/volumes/`, can
  be limited with `ephemeral-storage` limit on the pod, otherwise it can write
  until the partition hits 0% free space.
1. Container Logs (stdout / stderr)
1. Projected Volumes (Secrets, ConfigMaps, Downward API)

##### 1.1. Container logs directory
You configure this in the Kubelet Configuration file (usually
`/var/lib/kubelet/config.yaml` or passed as flags):
| Parameter | Recommended Value | Description |
| --------- | ----------------- | ----------- |
| containerLogMaxSize | 10Mi | When a log file hits 10MB, it is "rotated" (closed and a new one started). |
| containerLogMaxFiles | 3 | Keep only the 3 most recent 10MB files. The oldest is deleted. |
Total Max Logs **per container**: $10\text{Mi} \times 3 = 30\text{Mi}$.

The Path: By default, Kubernetes stores container logs in `/var/log/pods`.
However, on many systems, `/var/log` is part of the root partition, or
`/var/log/pods` is symlinked into `/var/lib/kubelet`.

The Action: A pod running a loop like `while true; do echo "FILL DISK"; done`
will generate massive JSON log files.

The Result: If these logs aren't rotated quickly enough, they will trigger a
DiskPressure eviction.

##### 1.2. Projected volumes
Every time a pod mounts a Secret or a ConfigMap, the Kubelet creates a local
file to represent that data.

The Action: If a user creates thousands of pods, each mounting a massive 1MB
ConfigMap.

The Impact: While 1MB isn't much, 1,000 pods means 1GB of metadata storage just
for configuration files.


##### 1.3 The `resources.limits.ephemeral-storage`
Imagine a container with:
```yaml
resources:
  limits:
    ephemeral-storage: "1Gi"
```
The Kubelet periodically scans the stdout/stderr log directory. If the sum of
(Logs + emptyDir + Writable Layer) exceeds 1Gi, the Kubelet will evict (kill)
the pod.


### 2. imagefs - Container Runtime dir
The Container Runtime directory contains:
1. Image layers
1. Container writable layers (snapshots) - like the `/` in containers
1. Runtime metadata
1. Sandboxes (pause containers)
1. Content blobs
1. GC state

Sample default values, for some of the popular container runtimes:
- containerd: `/var/lib/containerd`
- Docker: `/var/lib/docker`

### 3. Q/A
1. Q: Installing packages in the `/` "OS" inside a container counts as what type
of storage?

A: Those bytes go into the `container writable layer`, which lives in the
Container Runtime directory. For containerd it would be in:
`/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/`.

2. Q: Bytes in empty-dir-volumes count as what type of storage?

A: These bytes are counted as `ephemeral-storage` and go into the Kubelet
directory, in:
`/var/lib/kubelet/pods/{pod_uid}/volumes/kubernetes.io~empty-dir/`. Except if
your emptyDir volume is defined with a `medium: Memory`, then it doesn't touch
the disk at all (it's stored in RAM).


