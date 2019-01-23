# Exercise 6.3 - Parsing unstructured data with TextFSM


In a exercise, we ran the command `show ip interface brief` and just printed out the raw output.  Unfortunately, this
unstructured data is difficult to work with in Ansible, so we'll look at how to turn it into structured data using the
capabilities provided by [TextFSM](https://github.com/google/textfsm) in the `parse_cli_textfsm` module.


#### Step 1

The `ios_command` module allows you to do that. Go ahead and add another task to the playbook to collect the output of 2 _show_ commands to collect the **hostname** and the output of the `show ip interface brief` commands:

Create a file named `textfsm.yml` with the following contents:

```yaml
- name: GATHER INFORMATION FROM ROUTERS
  hosts: routers
  connection: network_cli
  gather_facts: no

  tasks:
    - name: COLLECT OUTPUT OF SHOW COMMANDS
      cli_command:
        command: show ip interface brief
      register: output
      
    - debug:
        var: output
```

Run the playbook. For brevity, we are going to limit the number of devices with the `--limit` option:

```shell
$ ansible-playbook textfsm.yml --limit=core

PLAY [GATHER INFORMATION FROM ROUTERS] *********************************************************************************************************

TASK [COLLECT OUTPUT OF SHOW COMMANDS] *********************************************************************************************************
ok: [core]

TASK [debug] ***********************************************************************************************************************************
ok: [core] => {
    "output": {
        "changed": false,
        "failed": false,
        "stdout": "Interface              IP-Address      OK? Method Status                Protocol\nGigabitEthernet1       192.133.178.89  YES DHCP   up                    up      \nGigabitEthernet2       10.0.255.2      YES TFTP   up                    up      \nGigabitEthernet3       10.0.1.1        YES TFTP   up                    up      \nGigabitEthernet4       10.0.255.5      YES TFTP   up                    up",
        "stdout_lines": [
            "Interface              IP-Address      OK? Method Status                Protocol",
            "GigabitEthernet1       192.133.178.89  YES DHCP   up                    up      ",
            "GigabitEthernet2       10.0.255.2      YES TFTP   up                    up      ",
            "GigabitEthernet3       10.0.1.1        YES TFTP   up                    up      ",
            "GigabitEthernet4       10.0.255.5      YES TFTP   up                    up"
        ]
    }
}

PLAY RECAP *************************************************************************************************************************************
core                       : ok=2    changed=0    unreachable=0    failed=0
```

### Step 2

Now, instead of just printing out the output, we pass it through the `parse_cli_textfsm` module and print out the variable
to which we assigned the results:

```yaml
- name: GATHER INFORMATION FROM ROUTERS
  hosts: routers
  connection: network_cli
  gather_facts: no

  tasks:
    - name: COLLECT OUTPUT OF SHOW COMMANDS
      cli_command:
        command: show ip interface brief
      register: output

    - set_fact:
        interfaces: "{{ output.stdout | parse_cli_textfsm('templates/ios_show_interfaces.textfsm') }}"

    - debug:
        var: interfaces

    - debug:
        msg: "The name of the first interface is {{ interfaces[0].INTERFACE }} and its IP is {{ interfaces[0].IP }}"
```

Run the playbook:

```shell
$ ansible-playbook textfsm.yml --limit=core

PLAY [GATHER INFORMATION FROM ROUTERS] *********************************************************************************************************

TASK [COLLECT OUTPUT OF SHOW COMMANDS] *********************************************************************************************************
ok: [core]

TASK [set_fact] ********************************************************************************************************************************
ok: [core]

TASK [debug] ***********************************************************************************************************************************
ok: [core] => {
    "interfaces": [
        {
            "INTERFACE": "GigabitEthernet1",
            "IP": "192.133.178.89",
            "METHOD": "DHCP",
            "OK": "YES",
            "PROTOCOL": "up",
            "STATUS": "up"
        },
        {
            "INTERFACE": "GigabitEthernet2",
            "IP": "10.0.255.2",
            "METHOD": "TFTP",
            "OK": "YES",
            "PROTOCOL": "up",
            "STATUS": "up"
        },
        {
            "INTERFACE": "GigabitEthernet3",
            "IP": "10.0.1.1",
            "METHOD": "TFTP",
            "OK": "YES",
            "PROTOCOL": "up",
            "STATUS": "up"
        },
        {
            "INTERFACE": "GigabitEthernet4",
            "IP": "10.0.255.5",
            "METHOD": "TFTP",
            "OK": "YES",
            "PROTOCOL": "up",
            "STATUS": "up"
        }
    ]
}

TASK [debug] ***********************************************************************************************************************************
ok: [core] => {
    "msg": "The name of the first interface is GigabitEthernet1 and its IP is 192.133.178.89"
}

PLAY RECAP *************************************************************************************************************************************
core                       : ok=4    changed=0    unreachable=0    failed=0                     : ok=3    changed=0    unreachable=0    failed=0
```

>NOTE: We were able to reference specific value from the data structure.

## Complete

You have completed lab exercise 6.3

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)
