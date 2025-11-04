```sql
-- -------------------------------------------------------------------------- --
-- Galera
-- -------------------------------------------------------------------------- --
-- Total active members in the cluster. Must match your expected node count for
-- full health. If it drops below 1, the node is isolated.
show status like 'wsrep_cluster_size';
-- The most important indicator of node health. This should be Synced. If this
-- is Joining, Donor/Desynced, or Joined, the node is not ready for active
-- replication/traffic.
show status like 'wsrep_local_state_comment';
-- Indicates this node belongs to the Primary Component. If this is Non-Primary,
-- your cluster has lost quorum and cannot safely process writes.
show status like 'wsrep_cluster_status';
-- Simple boolean check. If OFF, the node cannot process traffic or participate
-- in replication.
show status like 'wsrep_ready';
-- ncoming Replication Queue Size. This is the number of transactions waiting to
-- be applied by the node. A consistently non-zero value (e.g., > 10) indicates
-- the node is falling behind (replication lag).
show status like 'wsrep_local_recv_queue';
-- Flow Control Time. The amount of time (in nanoseconds) that the cluster has
-- been paused to allow a slow node to catch up. A consistently high number
-- indicates one or more nodes are constantly throttling the cluster's write
-- speed.
show status like 'wsrep_flow_control_paused_ns';
-- The unique UUID identifying the current state/history of the entire cluster.
-- This UUID should be identical across all active nodes.
show status like 'wsrep_gcomm_uuid';
-- The transaction ID (sequence number) of the last transaction successfully
-- applied locally.
show status like 'wsrep_last_committed';
```
