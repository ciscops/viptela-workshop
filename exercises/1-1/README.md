# Using Ansible with Viptela SDx Workshop

## Requirements

* Ansible>=2.7.0
* ncclient
* sshpass
* pyOpenSSL
* netaddr
* The appropriate license file needs to be located at `licenses\viptela_serial_file.viptela`



## Step1

Cloning the workshop repo repo:

git clone `https://wwwin-github.cisco.com/ciscops/virl-viptela.git`


## Step 2

Navigate to the `viptela-workshop` directory.

```
$ cd networking-workshop/
```

## Step 3

Deploy Topology:

Create a .virlrc:
```
VIRL_USERNAME=guest
VIRL_PASSWORD=guest
VIRL_HOST=your.virl.server
```

run the `build` playbook to the build the topology:
```
ansible-playbook build.yml
```

This playbook will:
* Launch the topology file
* Wait until they show as reachable in VIRL

>Note: Other topologies can be built using the `topo_file` extra var:
```
ansible-playbook build.yml -e topo_file=other_topology.virl
```

