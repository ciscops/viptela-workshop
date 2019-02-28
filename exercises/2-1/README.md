# Exercise 2.1 - Module documentation, Registering output & tags


In the previous section you learned to use the `ios_facts` and the `debug` modules. The `debug` module had an input parameter called `msg` whereas the `ios_facts` module had no input parameters. As someone just starting out how would you know what these parameters were for a module?

There are 2 options.

- 1. Point your browser to https://docs.ansible.com > Network Modules and read the documentation

- 2. From the command line, issue the `ansible-doc <module-name>` to read the documentation on the control host.

#### Step 1
On the control host read the documentation about the `ios_facts` module and the `debug` module.


```shell
[student1@ansible networking-workshop]$ ansible-doc debug
```

What happens when you use `debug` without specifying any parameter?

```shell
[student1@ansible networking-workshop]$ ansible-doc ios_facts
```

How can you limit the facts collected ?



#### Step 2
In the previous section, you learned how to use the `ios_facts` module to collect device details. What if you wanted to collect the output of a `show` command that was not provided as a part of `ios_facts` ?

The `ios_command` module allows you to do that. Go ahead and add another task to the playbook to collect the output of 2 _show_ commands to collect the **hostname** and the output of the `show ip interface brief` commands:

```yaml

---
- name: GATHER INFORMATION FROM ROUTERS
  hosts: routers
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

    - name: COLLECT OUTPUT OF SHOW COMMANDS
      ios_command:
        commands:
          - show run | i hostname
          - show ip interface brief
```

> Note: **commands** is a parameter required by the **ios_module**. The input to this parameter is a "list" of IOS commands.


Before running the playbook, add a `tag` to the last task. Name it "show"

> Note: Tags can be added to tasks, plays or roles within a playbook. You can assign one or more tags to any given task/play/role. Tags allow you to selectively run parts of the playbook.


```yaml

---
- name: GATHER INFORMATION FROM ROUTERS
  hosts: routers
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


    - name: COLLECT OUTPUT OF SHOW COMMANDS
      ios_command:
        commands:
          - show run | i hostname
          - show ip interface brief
      tags: show
```

Now, selectively run the last task within the playbook using the `--tags` option:

```bash
$ ansible-playbook gather_ios_data.yml --tags=show

PLAY [GATHER INFORMATION FROM ROUTERS] *********************************************************************************************************

TASK [COLLECT OUTPUT OF SHOW COMMANDS] *********************************************************************************************************
ok: [sp1]
ok: [core]
ok: [hq]
ok: [internet]

PLAY RECAP *************************************************************************************************************************************
core                       : ok=1    changed=0    unreachable=0    failed=0
hq                         : ok=1    changed=0    unreachable=0    failed=0
internet                   : ok=1    changed=0    unreachable=0    failed=0
sp1                        : ok=1    changed=0    unreachable=0    failed=0
```

Note 2 important points here:

1. Only a single task was executed during the playbook run (You no longer can see the serial number and IOS version being displayed)

2. The output of the show commands is not being displayed.


#### Step 3

With the `ios_facts` module, the output was automatically assigned to the `ansible_*` variables. For any of the ad-hoc commands we run against remote devices, the output has to be "registered" to a variable in order to use it within the playbook. Go ahead and add the `register` directive to collect the output of the show commands into a variable called `show_output`:


```

---
- name: GATHER INFORMATION FROM ROUTERS
  hosts: routers
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

    - name: COLLECT OUTPUT OF SHOW COMMANDS
      ios_command:
        commands:
          - show run | i hostname
          - show ip interface brief
      tags: show
      register: show_output

```

Then add a task to use the `debug` module to display the content's of the `show_output` variable. Tag this task as "show" as well.

``` yaml

---
- name: GATHER INFORMATION FROM ROUTERS
  hosts: routers
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

    - name: COLLECT OUTPUT OF SHOW COMMANDS
      ios_command:
        commands:
          - show run | i hostname
          - show ip interface brief
      tags: show
      register: show_output

    - name: DISPLAY THE COMMAND OUTPUT
      debug:
        var: show_output
      tags: show

```

> Note the use of **var** vs **msg** for the debug module.


Now re-run the playbook to execute only the tasks that have been tagged. This time run the playbook without the `-v` flag.


```
$ ansible-playbook gather_ios_data.yml --tags=show

PLAY [GATHER INFORMATION FROM ROUTERS] *********************************************************************************************************

TASK [COLLECT OUTPUT OF SHOW COMMANDS] *********************************************************************************************************
ok: [hq]
ok: [sp1]
ok: [internet]
ok: [core]

TASK [DISPLAY THE COMMAND OUTPUT] **************************************************************************************************************
ok: [core] => {
    "show_output": {
        "changed": false,
        "failed": false,
        "stdout": [
            "hostname core",
            "Interface              IP-Address      OK? Method Status                Protocol\nGigabitEthernet1       192.133.178.89  YES DHCP   up                    up      \nGigabitEthernet2       10.0.255.2      YES TFTP   up                    up      \nGigabitEthernet3       10.0.1.1        YES TFTP   up                    up      \nGigabitEthernet4       10.0.255.5      YES TFTP   up                    up"
        ],
        "stdout_lines": [
            [
                "hostname core"
            ],
            [
                "Interface              IP-Address      OK? Method Status                Protocol",
                "GigabitEthernet1       192.133.178.89  YES DHCP   up                    up      ",
                "GigabitEthernet2       10.0.255.2      YES TFTP   up                    up      ",
                "GigabitEthernet3       10.0.1.1        YES TFTP   up                    up      ",
                "GigabitEthernet4       10.0.255.5      YES TFTP   up                    up"
            ]
        ]
    }
}
ok: [sp1] => {
    "show_output": {
        "changed": false,
        "failed": false,
        "stdout": [
            "hostname sp1",
            "Interface              IP-Address      OK? Method Status                Protocol\nGigabitEthernet1       192.133.178.92  YES DHCP   up                    up      \nGigabitEthernet2       172.20.0.18     YES TFTP   up                    up      \nGigabitEthernet3       10.100.1.1      YES TFTP   up                    up"
        ],
        "stdout_lines": [
            [
                "hostname sp1"
            ],
            [
                "Interface              IP-Address      OK? Method Status                Protocol",
                "GigabitEthernet1       192.133.178.92  YES DHCP   up                    up      ",
                "GigabitEthernet2       172.20.0.18     YES TFTP   up                    up      ",
                "GigabitEthernet3       10.100.1.1      YES TFTP   up                    up"
            ]
        ]
    }
}
ok: [hq] => {
    "show_output": {
        "changed": false,
        "failed": false,
        "stdout": [
            "hostname hq",
            "Interface              IP-Address      OK? Method Status                Protocol\nGigabitEthernet1       192.133.178.90  YES DHCP   up                    up      \nGigabitEthernet2       172.20.0.6      YES TFTP   up                    up      \nGigabitEthernet3       10.0.0.1        YES TFTP   up                    up      \nGigabitEthernet4       10.0.255.1      YES TFTP   up                    up      \nGigabitEthernet5       unassigned      YES unset  administratively down down    \nGigabitEthernet6       unassigned      YES unset  administratively down down"
        ],
        "stdout_lines": [
            [
                "hostname hq"
            ],
            [
                "Interface              IP-Address      OK? Method Status                Protocol",
                "GigabitEthernet1       192.133.178.90  YES DHCP   up                    up      ",
                "GigabitEthernet2       172.20.0.6      YES TFTP   up                    up      ",
                "GigabitEthernet3       10.0.0.1        YES TFTP   up                    up      ",
                "GigabitEthernet4       10.0.255.1      YES TFTP   up                    up      ",
                "GigabitEthernet5       unassigned      YES unset  administratively down down    ",
                "GigabitEthernet6       unassigned      YES unset  administratively down down"
            ]
        ]
    }
}
ok: [internet] => {
    "show_output": {
        "changed": false,
        "failed": false,
        "stdout": [
            "hostname internet",
            "Interface              IP-Address      OK? Method Status                Protocol\nGigabitEthernet1       192.133.178.91  YES DHCP   up                    up      \nGigabitEthernet2       172.20.0.5      YES TFTP   up                    up      \nGigabitEthernet3       172.20.0.9      YES TFTP   up                    up      \nGigabitEthernet4       172.20.0.13     YES TFTP   up                    up      \nGigabitEthernet5       172.20.0.17     YES TFTP   up                    up      \nGigabitEthernet6       172.20.0.21     YES TFTP   up                    up"
        ],
        "stdout_lines": [
            [
                "hostname internet"
            ],
            [
                "Interface              IP-Address      OK? Method Status                Protocol",
                "GigabitEthernet1       192.133.178.91  YES DHCP   up                    up      ",
                "GigabitEthernet2       172.20.0.5      YES TFTP   up                    up      ",
                "GigabitEthernet3       172.20.0.9      YES TFTP   up                    up      ",
                "GigabitEthernet4       172.20.0.13     YES TFTP   up                    up      ",
                "GigabitEthernet5       172.20.0.17     YES TFTP   up                    up      ",
                "GigabitEthernet6       172.20.0.21     YES TFTP   up                    up"
            ]
        ]
    }
}

PLAY RECAP *************************************************************************************************************************************
core                       : ok=2    changed=0    unreachable=0    failed=0
hq                         : ok=2    changed=0    unreachable=0    failed=0
internet                   : ok=2    changed=0    unreachable=0    failed=0
sp1                        : ok=2    changed=0    unreachable=0    failed=0
```

#### Step 4

The `show_output` variable can now be parsed just like a `Python` dictionary. It contains a "key" called `stdout`. `stdout` is a list object, and will contain exactly as many elements as were in the input to the `commands` parameter of the `ios_command` task. This means `show_output.stdout[0]` will contain the output of the `show running | i hostname` command and `show_output.stdout[1]` will contain the output of `show ip interface brief`.

Write a new task to display only the hostname using a debug command:


``` yaml

---
- name: GATHER INFORMATION FROM ROUTERS
  hosts: routers
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

    - name: COLLECT OUTPUT OF SHOW COMMANDS
      ios_command:
        commands:
          - show run | i hostname
          - show ip interface brief
      tags: show
      register: show_output

    - name: DISPLAY THE COMMAND OUTPUT
      debug:
        var: show_output
      tags: show

    - name: DISPLAY THE HOSTNAME
      debug:
        msg: "The hostname is {{ show_output.stdout[0] }}"
      tags: show

```

Re-run the playbook.

```
$ ansible-playbook gather_ios_data.yml --tags=show

PLAY [GATHER INFORMATION FROM ROUTERS] *********************************************************************************************************

TASK [COLLECT OUTPUT OF SHOW COMMANDS] *********************************************************************************************************
ok: [sp1]
ok: [hq]
ok: [internet]
ok: [core]

TASK [DISPLAY THE COMMAND OUTPUT] **************************************************************************************************************
ok: [core] => {
    "show_output": {
        "changed": false,
        "failed": false,
        "stdout": [
            "hostname core",
            "Interface              IP-Address      OK? Method Status                Protocol\nGigabitEthernet1       192.133.178.89  YES DHCP   up                    up      \nGigabitEthernet2       10.0.255.2      YES TFTP   up                    up      \nGigabitEthernet3       10.0.1.1        YES TFTP   up                    up      \nGigabitEthernet4       10.0.255.5      YES TFTP   up                    up"
        ],
        "stdout_lines": [
            [
                "hostname core"
            ],
            [
                "Interface              IP-Address      OK? Method Status                Protocol",
                "GigabitEthernet1       192.133.178.89  YES DHCP   up                    up      ",
                "GigabitEthernet2       10.0.255.2      YES TFTP   up                    up      ",
                "GigabitEthernet3       10.0.1.1        YES TFTP   up                    up      ",
                "GigabitEthernet4       10.0.255.5      YES TFTP   up                    up"
            ]
        ]
    }
}
ok: [sp1] => {
    "show_output": {
        "changed": false,
        "failed": false,
        "stdout": [
            "hostname sp1",
            "Interface              IP-Address      OK? Method Status                Protocol\nGigabitEthernet1       192.133.178.92  YES DHCP   up                    up      \nGigabitEthernet2       172.20.0.18     YES TFTP   up                    up      \nGigabitEthernet3       10.100.1.1      YES TFTP   up                    up"
        ],
        "stdout_lines": [
            [
                "hostname sp1"
            ],
            [
                "Interface              IP-Address      OK? Method Status                Protocol",
                "GigabitEthernet1       192.133.178.92  YES DHCP   up                    up      ",
                "GigabitEthernet2       172.20.0.18     YES TFTP   up                    up      ",
                "GigabitEthernet3       10.100.1.1      YES TFTP   up                    up"
            ]
        ]
    }
}
ok: [hq] => {
    "show_output": {
        "changed": false,
        "failed": false,
        "stdout": [
            "hostname hq",
            "Interface              IP-Address      OK? Method Status                Protocol\nGigabitEthernet1       192.133.178.90  YES DHCP   up                    up      \nGigabitEthernet2       172.20.0.6      YES TFTP   up                    up      \nGigabitEthernet3       10.0.0.1        YES TFTP   up                    up      \nGigabitEthernet4       10.0.255.1      YES TFTP   up                    up      \nGigabitEthernet5       unassigned      YES unset  administratively down down    \nGigabitEthernet6       unassigned      YES unset  administratively down down"
        ],
        "stdout_lines": [
            [
                "hostname hq"
            ],
            [
                "Interface              IP-Address      OK? Method Status                Protocol",
                "GigabitEthernet1       192.133.178.90  YES DHCP   up                    up      ",
                "GigabitEthernet2       172.20.0.6      YES TFTP   up                    up      ",
                "GigabitEthernet3       10.0.0.1        YES TFTP   up                    up      ",
                "GigabitEthernet4       10.0.255.1      YES TFTP   up                    up      ",
                "GigabitEthernet5       unassigned      YES unset  administratively down down    ",
                "GigabitEthernet6       unassigned      YES unset  administratively down down"
            ]
        ]
    }
}
ok: [internet] => {
    "show_output": {
        "changed": false,
        "failed": false,
        "stdout": [
            "hostname internet",
            "Interface              IP-Address      OK? Method Status                Protocol\nGigabitEthernet1       192.133.178.91  YES DHCP   up                    up      \nGigabitEthernet2       172.20.0.5      YES TFTP   up                    up      \nGigabitEthernet3       172.20.0.9      YES TFTP   up                    up      \nGigabitEthernet4       172.20.0.13     YES TFTP   up                    up      \nGigabitEthernet5       172.20.0.17     YES TFTP   up                    up      \nGigabitEthernet6       172.20.0.21     YES TFTP   up                    up"
        ],
        "stdout_lines": [
            [
                "hostname internet"
            ],
            [
                "Interface              IP-Address      OK? Method Status                Protocol",
                "GigabitEthernet1       192.133.178.91  YES DHCP   up                    up      ",
                "GigabitEthernet2       172.20.0.5      YES TFTP   up                    up      ",
                "GigabitEthernet3       172.20.0.9      YES TFTP   up                    up      ",
                "GigabitEthernet4       172.20.0.13     YES TFTP   up                    up      ",
                "GigabitEthernet5       172.20.0.17     YES TFTP   up                    up      ",
                "GigabitEthernet6       172.20.0.21     YES TFTP   up                    up"
            ]
        ]
    }
}

TASK [DISPLAY THE HOSTNAME] ********************************************************************************************************************
ok: [hq] => {
    "msg": "The hostname is hostname hq"
}
ok: [internet] => {
    "msg": "The hostname is hostname internet"
}
ok: [sp1] => {
    "msg": "The hostname is hostname sp1"
}
ok: [core] => {
    "msg": "The hostname is hostname core"
}

PLAY RECAP *************************************************************************************************************************************
core                       : ok=3    changed=0    unreachable=0    failed=0
hq                         : ok=3    changed=0    unreachable=0    failed=0
internet                   : ok=3    changed=0    unreachable=0    failed=0
sp1                        : ok=3    changed=0    unreachable=0    failed=0
```

## Complete

You have completed lab exercise 2.1

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)
