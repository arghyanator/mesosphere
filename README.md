mesos_cluster Cookbook
======================
Create a Multi-node Mesos and Marathon Cluster

References: 
http://mesosphere.com/docs/getting-started/datacenter/install/
http://mesosphere.com/docs/tutorials/launch-docker-container-on-mesosphere/

Note: from second reference link - we would be using docker and marathon and not Chronos.


Requirements
------------
Apache Mesos, Marathon and ZooKeeper

Chef Node Attributes:
--------------------
```json
Mesos Master:
mesos_node = yes
mesos_installed = [yes,no]
mesos_master = [yes,no]

Mesos Slave:
mesos_node = yes
mesos_installed = [yes,no]
mesos_slave = [yes,no]
``` 

Chef Data bag (mesos_cluster) created in the following manner:
-------------------------------------------------------------
```json
{
  "id": "mesos_cluster",
  "master_nodeid1": "<mesos_master_node1_hostname>",
  "master_nodeid2": "<mesos_master_node2_hostname>",
  "master_nodeid3": "<mesos_master_node3_hostname>",
  "master_nodeid1_ip": "<mesos_master_node1_ip>",
  "master_nodeid2_ip": "<mesos_master_node2_ip>",
  "master_nodeid3_ip": "<mesos_master_node3_ip>",
  "slave_nodeid1": "<mesos_master_node1_hostname>",
  "slave_nodeid2": "<mesos_master_node2_hostname>",
  "slave_nodeid3": "<mesos_master_node3_hostname>",
  "slave_nodeid1_ip": "<mesos_slave_node1_ip>",
  "slave_nodeid2_ip": "<mesos_slave_node2_ip>",
  "slave_nodeid3_ip": "<mesos_slave_node3_ip>"
}
```


Attributes
----------

Uses Node Attributes for "Mesos Master" and "Mesos slave" and databag where all master and slave information are stored.

Usage
-----
#### mesos_cluster::default

Just include `mesos_cluster` in your node's `run_list`:

```json
{
  "name":"master_node",
  "normal": {
    "mesos_node": "yes",
    "mesos_installed": "no",
    "mesos_master": "no",
    "tags": [
    ]
  }
  "run_list": [
    "recipe[mesos_cluster]"
  ]
}
```

```json
{
  "name":"slave_node",
  "normal": {
    "mesos_node": "yes",
    "mesos_installed": "no",
    "mesos_slave": "no",
    "tags": [
    ]
  }
  "run_list": [
    "recipe[mesos_cluster]"
  ]
}
```

Contributing
------------

License and Authors
-------------------
Authors: Arghya Banerjee
