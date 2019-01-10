# Using Ansible with Viptela SDx Workshop

## Requirements

* Ansible>=2.7.0
* ncclient
* sshpass
* pyOpenSSL
* netaddr
* The appropriate license file needs to be located at `licenses\viptela_serial_file.viptela`


## Cloning this repo:

git clone `https://wwwin-github.cisco.com/ciscops/virl-viptela.git`

## Deploy Topology

Create a .virlrc:
```
VIRL_USERNAME=guest
VIRL_PASSWORD=guest
VIRL_HOST=your.virl.server
```

Start the Topology
```
ansible-playbook build.yml
```

To build a certain topology:
```
ansible-playbook build.yml -e topo_file=other_topology.virl
```

This playbook will:
* Launch the topology file
* Wait until they show as reachable in VIRL