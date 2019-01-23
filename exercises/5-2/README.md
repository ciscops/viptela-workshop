# Exercise 5.2 - Configure the Viptela vEdges

#### Step 1

Provision the vEdges in the topology:

```shell
ansible-playbook configure.yml --tags=edge
```

This playbook will:
* Push private CA to the vedges
* Bootstrap the vedges
* Add vedges to vmanage
* Check full connectivity

#### Step 2

Verify just the control plane by using the `check_edge` tag:

```shell
ansible-playbook configure.yml --tags=check_edge
```

#### Step 3

Finally, modify the playbook `viptela-devices.yml` to just print out all of the vedges.  The output should look similar
to the following:

```bash
$ ansible-playbook viptela-devices.yml

PLAY [localhost] *******************************************************************************************************************************

TASK [Get Cookie] ******************************************************************************************************************************
ok: [localhost]

TASK [Get a list of fabric devices] ************************************************************************************************************
ok: [localhost]

TASK [set_fact] ********************************************************************************************************************************
ok: [localhost]

TASK [debug] ***********************************************************************************************************************************
ok: [localhost] => {
    "msg": "These vedges are part of the fabric: vedge-hq,vedge1,vedge2"
}

PLAY RECAP *************************************************************************************************************************************
localhost                  : ok=4    changed=0    unreachable=0    failed=0
```

## Complete

You have completed lab exercise 5.2

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)