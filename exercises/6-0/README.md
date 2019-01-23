# Exercise 6.0 - Updating the router configuration with NETCONF

Using Ansible you can update the configuration of routers either by pushing a configuration file to the device or you can push configuration lines directly to the device.

#### Step 1

Create a new file called `ntp-netconf.yml` with the following play and task to ensure that the NTP servers are present on all the routers.  Use the `netconf_rpc` module for this task

> Note: For help on the **netconf_rpc** module, use the **ansible-doc netconf_rpc** command from the command line or check docs.ansible.com. This will list all possible options with usage examples.

```

---
- hosts: routers
  connection: netconf
  gather_facts: no
  tasks:
    - name: ENABLE NETCONF/YANG
      ios_config:
        commands:
          - netconf-yang
      connection: network_cli

    - netconf_rpc:
        rpc: edit-config
        content: |
          <target>
            <running/>
          </target>
          <config>
            <native xmlns="http://cisco.com/ns/yang/Cisco-IOS-XE-native">
              <ntp>
                <server xmlns="http://cisco.com/ns/yang/Cisco-IOS-XE-ntp" operation='replace'>
                  <server-list>
                    <ip-address>1.1.1.1</ip-address>
                  </server-list>
                  <server-list>
                    <ip-address>3.3.3.3</ip-address>
                  </server-list>
                </server>
              </ntp>
            </native>
          </config>
```

Run the playbook:

``` shell
$ ansible-playbook ntp-netconf.yml

PLAY [CONFIGURE ROUTERS] *****************************************************************************************************

TASK [ENABLE NETCONF/YANG] ***************************************************************************************************
ok: [sp1]
ok: [core]
ok: [hq]
ok: [internet]

TASK [ENSURE THAT THE DESIRED NTP SERVERS ARE PRESENT] ***********************************************************************
ok: [core]
ok: [hq]
ok: [internet]
ok: [sp1]

PLAY RECAP *******************************************************************************************************************
core                       : ok=2    changed=0    unreachable=0    failed=0
hq                         : ok=2    changed=0    unreachable=0    failed=0
internet                   : ok=2    changed=0    unreachable=0    failed=0
sp1                        : ok=2    changed=0    unreachable=0    failed=0                       : ok=1    changed=0    unreachable=0    failed=0
```

Feel free to log in and check the configuration update.

>Note: The **netconf_rpc** module simply sends the XML content for a particular operation.  There is no idempotency because
there is no checking beforehand.  The **netconf_config** module _is_ idempotent, but very problematic.

>Note: We specified `operation='replace'` in the payload to change from the default merge behavior.

>Note: The netconf modules all require the `netconf` connection type.

## Complete

You have completed lab exercise 6.0

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)
