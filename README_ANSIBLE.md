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

### Configure the Viptela Overlay

There are two ways to specify the org name for the tooling.  First, pass in as an extra var: 

```
ansible-playbook configure.yml -e 'organization_name="<your org name>"'
```

The second way is to modify `organization_name` in `inventory/group_vars/all/viptela.yml`.

```
organization_name: ""
```

This playbook will:
* Check for the existance of the license file
* Check initial connectivity
* Generate a local CA
* Configure all Viptela elements
* Create CSR, sign CSR, and install certificate
* Add vbond and vsmart to vmanage
* Push private CA to the vedges
* Bootstrap the vedges
* Add vedges to vmanage
* Check full connectivity

The playbook can be run with tags to only perform certain stages.  For example:

```
ansible-playbook configure.yml --tags=control
```
will only provision and configure the control plane.  The `CA` tag will only create the private CA.  The `check_connectivty` will only check the connectivity of the overlay.
 

### Clean up the Topology
```
ansible-playbook clean.yml
```

This playbook will:
* Remove topology devices from the `known_hosts` file
* Remove the `myCA` directory
* Destroy the topology specified in the .virlrc file