# VIRL Setup
## Create Flavors
The current VIRL API does not support creating flavors with ephemeral storage, so you must ssh to the VIRL servers as `virl` and run the following:

```
openstack flavor create --vcpus 4 --ram 4096 --disk 20 --ephemeral 20 vManage
openstack flavor create --vcpus 2 --ram 2048 --disk 11 vBond
openstack flavor create --vcpus 2 --ram 2048 --disk 11 vSmart
openstack flavor create --vcpus 2 --ram 2048 --disk 11 vEdge
```
