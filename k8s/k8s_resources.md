# Resources in K8s

## RAM
### Formula
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
or 100% threshold on an arbitrary resource. Note that eviction is looking at the
actual free RAM usage available on the Operating System, to see if it drops
below this threshold.

##### RAM `allocatable`
So, the allocatable space is actually calculated by the scheduler by subtracting
the `system_reserved`, `kube_reserved` and `hard_eviction_threshold` from the
`total_capcity`.

#### RAM example

For example, if you have a node with 12 GiB of RAM. You can allocate 2 GiB for
the OS, 1 GiB for Kube, and set the hard eviction at 1GiB. This gives you an
allocatable space of 8 GiB (12-2-1-1). This 8 GiB can be used by K8s pods, as
they wish, and the scheduler will keep track of it's usage.

So you can have 8 GiB of pods, 2 GiB of OS+system processes and have Kube system
processes use up to 1 GiB of RAM, and still be good. Until the next malloc call
which will start eating the last 1 GiB of RAM, and will trigger the K8s hard
eviction, killing pods to free some of the 8 GiB of allocatable memory.

If however, the 2 GiB of the RAM that is reserved for the system, is not used
fully, but only 1/2 GiBs is used, then the eviction will not be triggered
because it still sees 2 GiB of free RAM (the 1 GiB allocated for eviction and
the 1 GiB of unsed system-reserved RAM).


