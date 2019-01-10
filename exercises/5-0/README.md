# Configure the Viptela control plane

There are two ways to specify the org name for the tooling.  First, pass in as an extra var: 

```
ansible-playbook configure.yml -e 'organization_name="<your org name>"'
```

The second way is to modify `organization_name` in `inventory/group_vars/all/viptela.yml`.

```
organization_name: ""
```

The playbook can be run with tags to only perform certain stages.  For example:

```
ansible-playbook configure.yml --tags=control
```
will only provision and configure the control plane.  The `CA` tag will only create the private CA.  The `check_connectivty` will only check the connectivity of the overlay.

This playbook will:
* Check for the existance of the license file
* Check initial connectivity
* Generate a local CA
* Configure all Viptela elements
* Create CSR, sign CSR, and install certificate
* Add vbond and vsmart to vmanage