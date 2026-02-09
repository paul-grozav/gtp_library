# Starting point
Start looking for top folders that use most disk space.
```sh
$ sudo du -hx --max-depth=1 / | sort -hr
```
# /var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/
If the use of disk space is mostly in this folder, you can take one of those IDs
and check what it is by running the following command:
```sh
$ sudo ctr -n k8s.io snapshots info 54321
ctr: snapshot 54321 does not exist: not found
```
Since this is not found, let's see if it is in use:
```sh
$ mount | grep "snapshots/54321"
overlay on /run/containerd/io.containerd.runtime.v2.task/k8s.io/ca5534a51dd04bbcebe9b23ba05f389466cf0c190f1f8f182d7eea92a9671d00/rootfs type overlay (rw,relatime,seclabel,lowerdir=/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/12347/fs:/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/12345/fs:/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/12346/fs:/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/12348/fs:/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/12349/fs:/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/12344/fs:/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/12343/fs:/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/12342/fs:/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/12340/fs:/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/12341/fs,upperdir=/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/54321/fs,workdir=/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/54321/work,index=off)
```
You can see the ID showing up in the end of the line. It is the upperdir (the
writable layer) for the container with ID starting with ca5534a5.... This means
that X bytes of data wasn't part of the original image. It's data written by the
application while it was running.

Now to find out which container is this, you can run the following command:
```sh
$ sudo crictl inspect --output go-template --template '{{index .status.labels "io.kubernetes.pod.namespace" }}/{{index .status.labels "io.kubernetes.pod.name" }}' ca5534a51dd04bbcebe9b23ba05f389466cf0c190f1f8f182d7eea92a9671d00
dummy-namespace/engine-ss-0
```
So it is the `engine-ss-0` pod in the `dummy-namespace` namespace. You can dig
deeper if you want and exec into that pod to see which files use the that disk
space.
