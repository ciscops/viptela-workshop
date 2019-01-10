# Exercise 1.1 - Writing your first playbook

Now that you have a fundamental grasp of the inventory file and the group/host variables, this section will walk you through building a playbook.

> This section will help you understand the components of a playbook while giving you an immediate baseline for using it within your own production environment!

#### Step 1:

> Ansible playbooks are **YAML** files. YAML is a structured encoding format that is also extremely human readable (unlike it's subset - the JSON format)


Create a new file called `gather_ios_data.yml` the following play definition and a task will use the `ios_facts` module to gather facts about each device in the group `routers`:


``` yaml

---
- name: GATHER INFORMATION FROM ROUTERS
  hosts: cisco
  connection: network_cli
  gather_facts: no

  tasks:
    - name: GATHER ROUTER FACTS
      ios_facts:
```

>A play is a list of tasks. Modules are pre-written code that perform the task.


Run the playbook - exit back into the command line of the control host and execute the following:

```
ansible-playbook gather_ios_data.yml

PLAY [GATHER INFORMATION FROM ROUTERS] *********************************************************************************************************

TASK [GATHER ROUTER FACTS] *********************************************************************************************************************
ok: [core]
ok: [hq]
ok: [sp1]
ok: [internet]

PLAY RECAP *************************************************************************************************************************************
core                       : ok=1    changed=0    unreachable=0    failed=0
hq                         : ok=1    changed=0    unreachable=0    failed=0
internet                   : ok=1    changed=0    unreachable=0    failed=0
sp1                        : ok=1    changed=0    unreachable=0    failed=0
```
>NOTE: `-i inventory` would normally be required it inventory was not specified in ansible.cfg


#### Step 2

The play ran successfully and executed against the 4 routers. But where is the output?! Re-run the playbook using the `-v` flag.

> Note: Ansible has increasing level of verbosity. You can use up to 4 "v's", -vvvv.


```
$ ansible-playbook gather_ios_data.yml -v
Using /Users/stevenca/Workspaces/viptela-workshop/ansible.cfg as config file
/Users/stevenca/Workspaces/viptela-workshop/inventory/viptela.yml did not meet host_list requirements, check plugin documentation if this is unexpected
/Users/stevenca/Workspaces/viptela-workshop/inventory/viptela.yml did not meet script requirements, check plugin documentation if this is unexpected
/Users/stevenca/Workspaces/viptela-workshop/inventory/virl.py did not meet host_list requirements, check plugin documentation if this is unexpected

PLAY [GATHER INFORMATION FROM ROUTERS] *********************************************************************************************************

TASK [GATHER ROUTER FACTS] *********************************************************************************************************************
ok: [core] => {"ansible_facts": {"ansible_net_all_ipv4_addresses": ["10.0.255.5", "192.133.178.89", "10.0.255.2", "10.0.1.1"], "ansible_net_all_ipv6_addresses": [], "ansible_net_filesystems": ["bootflash:"], "ansible_net_filesystems_info": {"bootflash:": {"spacefree_kb": 14179808, "spacetotal_kb": 16035260}}, "ansible_net_gather_subset": ["hardware", "default", "interfaces"], "ansible_net_hostname": "core", "ansible_net_image": "bootflash:packages.conf", "ansible_net_interfaces": {"GigabitEthernet1": {"bandwidth": 1000000, "description": "OOB Management", "duplex": "Full", "ipv4": [{"address": "192.133.178.89", "subnet": "23"}], "lineprotocol": "up ", "macaddress": "5e00.000a.0000", "mediatype": "RJ45", "mtu": 1500, "operstatus": "up", "type": "CSR vNIC"}, "GigabitEthernet2": {"bandwidth": 1000000, "description": "DC Border", "duplex": "Full", "ipv4": [{"address": "10.0.255.2", "subnet": "30"}], "lineprotocol": "up ", "macaddress": "fa16.3e72.6233", "mediatype": "RJ45", "mtu": 1500, "operstatus": "up", "type": "CSR vNIC"}, "GigabitEthernet3": {"bandwidth": 1000000, "description": "DC", "duplex": "Full", "ipv4": [{"address": "10.0.1.1", "subnet": "24"}], "lineprotocol": "up ", "macaddress": "fa16.3e1c.13d4", "mediatype": "RJ45", "mtu": 1500, "operstatus": "up", "type": "CSR vNIC"}, "GigabitEthernet4": {"bandwidth": 1000000, "description": "vedge-hq", "duplex": "Full", "ipv4": [{"address": "10.0.255.5", "subnet": "30"}], "lineprotocol": "up ", "macaddress": "fa16.3e7c.1ab3", "mediatype": "RJ45", "mtu": 1500, "operstatus": "up", "type": "CSR vNIC"}}, "ansible_net_memfree_mb": 880403, "ansible_net_memtotal_mb": 1225375, "ansible_net_model": "CSR1000V", "ansible_net_serialnum": "9G2BRFW90PE", "ansible_net_version": "16.06.01"}, "changed": false}
ok: [sp1] => {"ansible_facts": {"ansible_net_all_ipv4_addresses": ["192.133.178.92", "172.20.0.18", "10.100.1.1"], "ansible_net_all_ipv6_addresses": [], "ansible_net_filesystems": ["bootflash:"], "ansible_net_filesystems_info": {"bootflash:": {"spacefree_kb": 14179812, "spacetotal_kb": 16035260}}, "ansible_net_gather_subset": ["hardware", "default", "interfaces"], "ansible_net_hostname": "sp1", "ansible_net_image": "bootflash:packages.conf", "ansible_net_interfaces": {"GigabitEthernet1": {"bandwidth": 1000000, "description": "OOB Management", "duplex": "Full", "ipv4": [{"address": "192.133.178.92", "subnet": "23"}], "lineprotocol": "up ", "macaddress": "5e00.000c.0000", "mediatype": "RJ45", "mtu": 1500, "operstatus": "up", "type": "CSR vNIC"}, "GigabitEthernet2": {"bandwidth": 1000000, "description": "internet", "duplex": "Full", "ipv4": [{"address": "172.20.0.18", "subnet": "30"}], "lineprotocol": "up ", "macaddress": "fa16.3ecc.0e32", "mediatype": "RJ45", "mtu": 1500, "operstatus": "up", "type": "CSR vNIC"}, "GigabitEthernet3": {"bandwidth": 1000000, "description": "spdc", "duplex": "Full", "ipv4": [{"address": "10.100.1.1", "subnet": "24"}], "lineprotocol": "up ", "macaddress": "fa16.3ec8.6e44", "mediatype": "RJ45", "mtu": 1500, "operstatus": "up", "type": "CSR vNIC"}}, "ansible_net_memfree_mb": 877514, "ansible_net_memtotal_mb": 1225375, "ansible_net_model": "CSR1000V", "ansible_net_serialnum": "9IE01XYI86C", "ansible_net_version": "16.06.01"}, "changed": false}
ok: [internet] => {"ansible_facts": {"ansible_net_all_ipv4_addresses": ["172.20.0.13", "172.20.0.17", "172.20.0.21", "192.133.178.91", "172.20.0.5", "172.20.0.9"], "ansible_net_all_ipv6_addresses": [], "ansible_net_filesystems": ["bootflash:"], "ansible_net_filesystems_info": {"bootflash:": {"spacefree_kb": 14179808, "spacetotal_kb": 16035260}}, "ansible_net_gather_subset": ["hardware", "default", "interfaces"], "ansible_net_hostname": "internet", "ansible_net_image": "bootflash:packages.conf", "ansible_net_interfaces": {"GigabitEthernet1": {"bandwidth": 1000000, "description": "OOB Management", "duplex": "Full", "ipv4": [{"address": "192.133.178.91", "subnet": "23"}], "lineprotocol": "up ", "macaddress": "5e00.0000.0000", "mediatype": "RJ45", "mtu": 1500, "operstatus": "up", "type": "CSR vNIC"}, "GigabitEthernet2": {"bandwidth": 1000000, "description": "DC Border", "duplex": "Full", "ipv4": [{"address": "172.20.0.5", "subnet": "30"}], "lineprotocol": "up ", "macaddress": "fa16.3e25.ae41", "mediatype": "RJ45", "mtu": 1500, "operstatus": "up", "type": "CSR vNIC"}, "GigabitEthernet3": {"bandwidth": 1000000, "description": "to site1", "duplex": "Full", "ipv4": [{"address": "172.20.0.9", "subnet": "30"}], "lineprotocol": "up ", "macaddress": "fa16.3ead.f40c", "mediatype": "RJ45", "mtu": 1500, "operstatus": "up", "type": "CSR vNIC"}, "GigabitEthernet4": {"bandwidth": 1000000, "description": "to site2", "duplex": "Full", "ipv4": [{"address": "172.20.0.13", "subnet": "30"}], "lineprotocol": "up ", "macaddress": "fa16.3e5b.4fb3", "mediatype": "RJ45", "mtu": 1500, "operstatus": "up", "type": "CSR vNIC"}, "GigabitEthernet5": {"bandwidth": 1000000, "description": "to sp1", "duplex": "Full", "ipv4": [{"address": "172.20.0.17", "subnet": "30"}], "lineprotocol": "up ", "macaddress": "fa16.3e93.25af", "mediatype": "RJ45", "mtu": 1500, "operstatus": "up", "type": "CSR vNIC"}, "GigabitEthernet6": {"bandwidth": 1000000, "description": "to partner4", "duplex": "Full", "ipv4": [{"address": "172.20.0.21", "subnet": "30"}], "lineprotocol": "up ", "macaddress": "fa16.3e90.8451", "mediatype": "RJ45", "mtu": 1500, "operstatus": "up", "type": "CSR vNIC"}}, "ansible_net_memfree_mb": 877381, "ansible_net_memtotal_mb": 1225375, "ansible_net_model": "CSR1000V", "ansible_net_serialnum": "9NSC4T87AF2", "ansible_net_version": "16.06.01"}, "changed": false}
ok: [hq] => {"ansible_facts": {"ansible_net_all_ipv4_addresses": ["10.0.255.1", "192.133.178.90", "172.20.0.6", "10.0.0.1"], "ansible_net_all_ipv6_addresses": [], "ansible_net_filesystems": ["bootflash:"], "ansible_net_filesystems_info": {"bootflash:": {"spacefree_kb": 14179808, "spacetotal_kb": 16035260}}, "ansible_net_gather_subset": ["hardware", "default", "interfaces"], "ansible_net_hostname": "hq", "ansible_net_image": "bootflash:packages.conf", "ansible_net_interfaces": {"GigabitEthernet1": {"bandwidth": 1000000, "description": "OOB Management", "duplex": "Full", "ipv4": [{"address": "192.133.178.90", "subnet": "23"}], "lineprotocol": "up ", "macaddress": "5e00.0009.0000", "mediatype": "RJ45", "mtu": 1500, "operstatus": "up", "type": "CSR vNIC"}, "GigabitEthernet2": {"bandwidth": 1000000, "description": "Internet", "duplex": "Full", "ipv4": [{"address": "172.20.0.6", "subnet": "30"}], "lineprotocol": "up ", "macaddress": "fa16.3e70.1ef9", "mediatype": "RJ45", "mtu": 1500, "operstatus": "up", "type": "CSR vNIC"}, "GigabitEthernet3": {"bandwidth": 1000000, "description": "DMZ", "duplex": "Full", "ipv4": [{"address": "10.0.0.1", "subnet": "24"}], "lineprotocol": "up ", "macaddress": "fa16.3ea6.33fa", "mediatype": "RJ45", "mtu": 1500, "operstatus": "up", "type": "CSR vNIC"}, "GigabitEthernet4": {"bandwidth": 1000000, "description": "DC Core", "duplex": "Full", "ipv4": [{"address": "10.0.255.1", "subnet": "30"}], "lineprotocol": "up ", "macaddress": "fa16.3e1a.4772", "mediatype": "RJ45", "mtu": 1500, "operstatus": "up", "type": "CSR vNIC"}, "GigabitEthernet5": {"bandwidth": 1000000, "description": null, "duplex": "Full", "ipv4": [], "lineprotocol": "down ", "macaddress": "fa16.3e2b.5596", "mediatype": "RJ45", "mtu": 1500, "operstatus": "administratively down", "type": "CSR vNIC"}, "GigabitEthernet6": {"bandwidth": 1000000, "description": null, "duplex": "Full", "ipv4": [], "lineprotocol": "down ", "macaddress": "fa16.3eb9.60b9", "mediatype": "RJ45", "mtu": 1500, "operstatus": "administratively down", "type": "CSR vNIC"}}, "ansible_net_memfree_mb": 875017, "ansible_net_memtotal_mb": 1225375, "ansible_net_model": "CSR1000V", "ansible_net_serialnum": "9R9GMBNZ5KH", "ansible_net_version": "16.06.01"}, "changed": false}

PLAY RECAP *************************************************************************************************************************************
core                       : ok=1    changed=0    unreachable=0    failed=0
hq                         : ok=1    changed=0    unreachable=0    failed=0
internet                   : ok=1    changed=0    unreachable=0    failed=0
sp1                        : ok=1    changed=0    unreachable=0    failed=0.
```

> Note: The output returns key-value pairs that can then be used within the playbook for subsequent tasks. Also note that all variables that start with **ansible_** are automatically available for subsequent tasks within the play.


#### Step 3

Running a playbook in verbose mode is a good option to validate the output from a task. To work with the variables within a playbook you can use the `debug` module.

Write 2 tasks that display the routers' OS version and serial number.

``` yaml

---
- name: GATHER INFORMATION FROM ROUTERS
  hosts: cisco
  connection: network_cli
  gather_facts: no

  tasks:
    - name: GATHER ROUTER FACTS
      ios_facts:

    - name: DISPLAY VERSION
      debug:
        msg: "The IOS version is: {{ ansible_net_version }}"

    - name: DISPLAY SERIAL NUMBER
      debug:
        msg: "The serial number is:{{ ansible_net_serialnum }}"  
```

Now re-run the playbook but this time do not use the `verbose` flag and run it against all hosts.

```
$ ansible-playbook gather_ios_data.yml

PLAY [GATHER INFORMATION FROM ROUTERS] *********************************************************************************************************

TASK [GATHER ROUTER FACTS] *********************************************************************************************************************
ok: [core]
ok: [sp1]
ok: [hq]
ok: [internet]

TASK [DISPLAY VERSION] *************************************************************************************************************************
ok: [sp1] => {
    "msg": "The IOS version is: 16.06.01"
}
ok: [core] => {
    "msg": "The IOS version is: 16.06.01"
}
ok: [hq] => {
    "msg": "The IOS version is: 16.06.01"
}
ok: [internet] => {
    "msg": "The IOS version is: 16.06.01"
}

TASK [DISPLAY SERIAL NUMBER] *******************************************************************************************************************
ok: [core] => {
    "msg": "The serial number is:9G2BRFW90PE"
}
ok: [sp1] => {
    "msg": "The serial number is:9IE01XYI86C"
}
ok: [hq] => {
    "msg": "The serial number is:9R9GMBNZ5KH"
}
ok: [internet] => {
    "msg": "The serial number is:9NSC4T87AF2"
}

PLAY RECAP *************************************************************************************************************************************
core                       : ok=3    changed=0    unreachable=0    failed=0
hq                         : ok=3    changed=0    unreachable=0    failed=0
internet                   : ok=3    changed=0    unreachable=0    failed=0
sp1                        : ok=3    changed=0    unreachable=0    failed=0
```

#### Step 4

Ansible allows you to limit the playbook execution to a subset of the devices declared in the group, against which the play is running against. This can be done using the `--limit` flag. Rerun the above task, limiting it first to `rtr1` and then to both `rtr1` and `rtr3`


```
$ ansible-playbook gather_ios_data.yml --limit core

PLAY [GATHER INFORMATION FROM ROUTERS] *********************************************************************************************************

TASK [GATHER ROUTER FACTS] *********************************************************************************************************************
ok: [core]

TASK [DISPLAY VERSION] *************************************************************************************************************************
ok: [core] => {
    "msg": "The IOS version is: 16.06.01"
}

TASK [DISPLAY SERIAL NUMBER] *******************************************************************************************************************
ok: [core] => {
    "msg": "The serial number is:9G2BRFW90PE"
}

PLAY RECAP *************************************************************************************************************************************
core                       : ok=3    changed=0    unreachable=0    failed=0
```

# Complete

You have completed lab exercise 1.1

---
[Click Here to return to the Ansible Linklight - Networking Workshop](../../README.md)
