# Resources in K8s

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
When eviction kicks in for the RAM resource, the "punishment" is "hard",
killing the pods/processes. Unlike the CPU resource for example, for which the
punishment is "soft", just throttling the performance of those processes.

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
the system processes need it, the OS will have a higher priority. throttling the
pod's CPU usage.

#### CPU has no eviction
When eviction kicks in for the RAM resource, the "punishment" is "hard",
killing the pods/processes. However the CPU is a "compressible" resource. So the
punishment is "soft", just throttling the performance of those processes that
compete for the resources.

