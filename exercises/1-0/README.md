# Exercise 1.0 -  Using Ansible with Viptela SDx Workshop

## Requirements

* pip: `pip install -r requirements.txt`
* sshpass


## Step1

Cloning the workshop repo repo:

git clone `https://github.com/ciscops/viptela-workshop.git`


## Step 2

Navigate to the `viptela-workshop` directory.

``` shell
$ cd viptela-workshop/
```

>Note: All subsequent exercises will be in this directory unless otherwise noted.

## Step 3

Deploy Topology:

Create a .virlrc:
``` shell
VIRL_USERNAME=guest
VIRL_PASSWORD=guest
VIRL_HOST=your.virl.server
```

Run the `build` playbook to the build the topology:
``` shell
ansible-playbook build.yml
```

This playbook will:
* Launch the topology file
* Wait until they show as reachable in VIRL

>Note: Other topologies can be built using the `topo_file` extra var:
``` shell
ansible-playbook build.yml -e topo_file=other_topology.virl
```

# Complete

You have completed lab exercise 1.0

[Click Here to return to the Viptela Networking Automation Workshop](README_AUTOMATION.md)
