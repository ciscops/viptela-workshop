# Exercise 5.0 -  Configure the Viptela control plane

## Requirements

* A license file located at `licenses\viptela_serial_file.viptela`
* The organization name associated with the license file.

There are two ways to specify the organization name for the tooling.  First, pass in as an extra var: 

```shell
ansible-playbook configure.yml -e 'organization_name="<your org name>"'
```

The second way is to modify `organization_name` in `inventory/group_vars/all/viptela.yml`.

```shell
organization_name: ""
```

The playbook can be run with tags to only perform certain stages.  For example:

```shell
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

## Complete

You have completed lab exercise 5.0

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)