# Exercise 4.0 - Updating the router configurations using Ansible

Using Ansible you can update the configuration of routers either by pushing a configuration file to the device or you can push configuration lines directly to the device.

#### Step 1

Create a new file called `router_configs.yml` with the following play and task to ensure that the SNMP strings `ansible-public` and `ansible-private` are present on all the routers.  Use the `ios_config` module for this task

> Note: For help on the **ios_config** module, use the **ansible-doc ios_config** command from the command line or check docs.ansible.com. This will list all possible options with usage examples.

```

---
- name: SNMP RO/RW STRING CONFIGURATION
  hosts: routers
  gather_facts: no
  connection: network_cli

  tasks:

    - name: ENSURE THAT THE DESIRED SNMP STRINGS ARE PRESENT
      ios_config:
        commands:
          - snmp-server community ansible-public RO
          - snmp-server community ansible-private RW
```

Run the playbook:

``` shell
$ ansible-playbook router_configs.yml

PLAY [SNMP RO/RW STRING CONFIGURATION] *********************************************************************************************************

TASK [ENSURE THAT THE DESIRED SNMP STRINGS ARE PRESENT] ****************************************************************************************
changed: [hq]
changed: [internet]
changed: [core]
changed: [sp1]

PLAY RECAP *************************************************************************************************************************************
core                       : ok=1    changed=1    unreachable=0    failed=0
hq                         : ok=1    changed=1    unreachable=0    failed=0
internet                   : ok=1    changed=1    unreachable=0    failed=0
sp1                        : ok=1    changed=1    unreachable=0    failed=0
```

Feel free to log in and check the configuration update.


#### Step 2

The `ios_config` module is idempotent. This means, a configuration change is pushed to the device if and only if that configuration does not exist on the end hosts. To validate this, go ahead and re-run the playbook:


``` shell
$ ansible-playbook router_configs.yml

PLAY [SNMP RO/RW STRING CONFIGURATION] *********************************************************************************************************

TASK [ENSURE THAT THE DESIRED SNMP STRINGS ARE PRESENT] ****************************************************************************************
ok: [core]
ok: [internet]
ok: [sp1]
ok: [hq]

PLAY RECAP *************************************************************************************************************************************
core                       : ok=1    changed=0    unreachable=0    failed=0
hq                         : ok=1    changed=0    unreachable=0    failed=0
internet                   : ok=1    changed=0    unreachable=0    failed=0
sp1                        : ok=1    changed=0    unreachable=0    failed=0
```

> Note: See that the **changed** parameter in the **PLAY RECAP** indicates 0 changes.


#### Step 3

Now update the task to add one more SNMP RO community string:


``` yaml

---
- name: UPDATE THE SNMP RO/RW STRINGS
  hosts: routers
  gather_facts: no
  connection: network_cli

  tasks:

    - name: ENSURE THAT THE DESIRED SNMP STRINGS ARE PRESENT
      ios_config:
        commands:
          - snmp-server community ansible-public RO
          - snmp-server community ansible-private RW
          - snmp-server community ansible-test RO

```


This time however, instead of running the playbook to push the change to the device, execute it using the `--check` flag in combination with the `-v` or verbose mode flag:


``` shell
$ ansible-playbook router_configs.yml --check -v
Using /Users/stevenca/Workspaces/viptela-workshop/ansible.cfg as config file
/Users/stevenca/Workspaces/viptela-workshop/inventory/viptela.yml did not meet host_list requirements, check plugin documentation if this is unexpected
/Users/stevenca/Workspaces/viptela-workshop/inventory/viptela.yml did not meet script requirements, check plugin documentation if this is unexpected
/Users/stevenca/Workspaces/viptela-workshop/inventory/virl.py did not meet host_list requirements, check plugin documentation if this is unexpected

PLAY [SNMP RO/RW STRING CONFIGURATION] *********************************************************************************************************

TASK [ENSURE THAT THE DESIRED SNMP STRINGS ARE PRESENT] ****************************************************************************************
changed: [hq] => {"banners": {}, "changed": true, "commands": ["snmp-server community ansible-test RO"], "updates": ["snmp-server community ansible-test RO"]}
changed: [internet] => {"banners": {}, "changed": true, "commands": ["snmp-server community ansible-test RO"], "updates": ["snmp-server community ansible-test RO"]}
changed: [sp1] => {"banners": {}, "changed": true, "commands": ["snmp-server community ansible-test RO"], "updates": ["snmp-server community ansible-test RO"]}
changed: [core] => {"banners": {}, "changed": true, "commands": ["snmp-server community ansible-test RO"], "updates": ["snmp-server community ansible-test RO"]}

PLAY RECAP *************************************************************************************************************************************
core                       : ok=1    changed=1    unreachable=0    failed=0
hq                         : ok=1    changed=1    unreachable=0    failed=0
internet                   : ok=1    changed=1    unreachable=0    failed=0
sp1                        : ok=1    changed=1    unreachable=0    failed=0
```

The `--check` mode in combination with the `-v` flag will display the exact changes that will be deployed to the end device without actually pushing the change. This is a great technique to validate the changes you are about to push to a device before pushing it.

> Go ahead and log into a couple of devices to validate that the change has not been pushed.


Also note that even though 3 commands are being sent to the device as part of the task, only the one command that is missing on the devices will be pushed.


#### Step 4

Finally re-run this playbook again without the `-v` or `--check` flag to push the changes.

``` shell
$ ansible-playbook router_configs.yml

PLAY [SNMP RO/RW STRING CONFIGURATION] *********************************************************************************************************

TASK [ENSURE THAT THE DESIRED SNMP STRINGS ARE PRESENT] ****************************************************************************************
changed: [core]
changed: [hq]
changed: [sp1]
changed: [internet]

PLAY RECAP *************************************************************************************************************************************
core                       : ok=1    changed=1    unreachable=0    failed=0
hq                         : ok=1    changed=1    unreachable=0    failed=0
internet                   : ok=1    changed=1    unreachable=0    failed=0
sp1                        : ok=1    changed=1    unreachable=0    failed=0
```


#### Step 5

Rather than push individual lines of configuration, an entire configuration snippet can be pushed to the devices. Create a file called `secure_router.cfg` in the same directory as your playbook and add the following lines of configuration into it:

``` shell
line con 0
 exec-timeout 5 0
line vty 0 4
 exec-timeout 5 0
 transport input ssh
ip ssh time-out 60
ip ssh authentication-retries 5
service password-encryption
service tcp-keepalives-in
service tcp-keepalives-out

```


#### Step 6

Remember that a playbook contains a list of plays. Add a new play called `HARDEN IOS ROUTERS` to the `router_configs.yml`
playbook with a task to push the configurations in the `secure_router.cfg` file you created in **STEP 5**

``` yaml

---
- name: UPDATE THE SNMP RO/RW STRINGS
  hosts: routers
  gather_facts: no
  connection: network_cli

  tasks:

    - name: ENSURE THAT THE DESIRED SNMP STRINGS ARE PRESENT
      ios_config:
        commands:
          - snmp-server community ansible-public RO
          - snmp-server community ansible-private RW
          - snmp-server community ansible-test RO


- name: HARDEN IOS ROUTERS
  hosts: routers
  gather_facts: no
  connection: network_cli

  tasks:

    - name: ENSURE THAT ROUTERS ARE SECURE
      ios_config:
        src: secure_router.cfg
```

Go ahead and run the playbook:

``` shell
$ ansible-playbook router_configs.yml

PLAY [SNMP RO/RW STRING CONFIGURATION] *********************************************************************************************************

TASK [ENSURE THAT THE DESIRED SNMP STRINGS ARE PRESENT] ****************************************************************************************
ok: [sp1]
ok: [hq]
ok: [core]
ok: [internet]

PLAY [HARDEN IOS ROUTERS] **********************************************************************************************************************

TASK [ENSURE THAT ROUTERS ARE SECURE] **********************************************************************************************************
changed: [hq]
changed: [internet]
changed: [core]
changed: [sp1]

PLAY RECAP *************************************************************************************************************************************
core                       : ok=2    changed=1    unreachable=0    failed=0
hq                         : ok=2    changed=1    unreachable=0    failed=0
internet                   : ok=2    changed=1    unreachable=0    failed=0
sp1                        : ok=2    changed=1    unreachable=0    failed=0
```

# Complete

You have completed lab exercise 2.0

---
[Click Here to return to the Ansible Linklight - Networking Workshop](../../README.md)
