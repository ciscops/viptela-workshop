# Exercise 5.0 -  Configure the Viptela control plane

## Requirements

* A license file located at `licenses\viptela_serial_file.viptela`
* The organization name associated with the license file.

#### Step 1

The easiest way to specify the organization name is to modify `organization_name` in `inventory/group_vars/all/viptela.yml`:

```shell
organization_name: ""
```

Now run `configure.yml` running only those plays with the tag `control`:

```shell
ansible-playbook configure.yml --tags=control
```

Alternatively, organization name can be passed in as an extra var (**note commas**): 

```shell
ansible-playbook configure.yml -e 'organization_name="<your org name>"' --tags=control
```

`configure.yml` can also be run with the following tags:
* `CA`: only create the private CA
* `control`: only provision the Viptela control plane
* `vedge`: only provision the Viptela vEdges
* `check_control`: check connectivity of the control plane
* `check_edge`: check connectivity of the edge
* `check_all`: check full connectivity of the overlay

This playbook will:
* Check for the existance of the license file
* Check initial connectivity
* Generate a local CA
* Configure all Viptela elements
* Create CSR, sign CSR, and install certificate
* Add vbond and vsmart to vmanage

#### Step 2

Verify just the control plane by using the `check_control` tag:

```shell
ansible-playbook configure.yml --tags=check_control
```

## Complete

You have completed lab exercise 5.0

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)