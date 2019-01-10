# Exercise 1.1 - Exploring the lab environment

## Step 1

Run the `ansible` command with the `--version` command to look at what is configured:


``` shell
$ ansible --version
ansible 2.7.4
  config file = /Users/stevenca/Workspaces/viptela-workshop/ansible.cfg
  configured module search path = [u'/Users/stevenca/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /Users/stevenca/venv/netops/lib/python2.7/site-packages/ansible
  executable location = /Users/stevenca/venv/netops/bin/ansible
  python version = 2.7.10 (default, Aug 17 2018, 17:41:52) [GCC 4.2.1 Compatible Apple LLVM 10.0.0 (clang-1000.0.42)]
```

> Note: The ansible version you see might differ from the above output


This command gives you information about the version of Ansible, location of the executable, version of Python, search path for the modules and location of the `ansible configuration file`.

## Step 2

Use the `cat` command to view the contents of the `ansible.cfg` file.

``` shell
$ cat ~/ansible.cfg
[defaults]
roles_path = ${PWD}/roles
host_key_checking = False
inventory = ./inventory
local_tmp = /tmp/ansible/${USER}
remote_tmp = /tmp/ansible/${USER}

[persistent_connection]
connect_timeout = 60
command_timeout = 60
```

## Step 3

The scope of a `play` within a `playbook` is limited to the groups of hosts declared within an Ansible **inventory**. Ansible supports multiple [inventory](http://docs.ansible.com/ansible/latest/intro_inventory.html) types. An inventory could be a simple flat file with a collection of hosts defined within it or it could be a dynamic script (potentially querying a CMDB backend) that generates a list of devices to run the playbook against.

This viptela workshop uses a combination of file based inventory written in the **yaml** format and dynamic inventory:
 
``` shell
inventory
├── group_vars
│   └── all
│       ├── credentials.yml
│       ├── system.yml
│       ├── viptela.yml
│       └── virl.yml
├── host_vars
│   ├── internet
│   │   └── interfaces.yml
│   ├── vbond1
│   │   ├── interfaces.yml
│   │   └── system.yml
│   ├── vedge-hq
│   │   ├── interfaces.yml
│   │   └── system.yml
│   ├── vedge1
│   │   ├── interfaces.yml
│   │   └── system.yml
│   ├── vedge2
│   │   ├── interfaces.yml
│   │   └── system.yml
│   ├── vmanage1
│   │   ├── interfaces.yml
│   │   └── system.yml
│   └── vsmart1
│       ├── interfaces.yml
│       └── system.yml
├── viptela.yml
└── virl.py
``` 

The IP addresses of the hosts in the VIRL environment are retrieved using the dynamic inventory script `virl.py`.  This inventory
script makes an API call to the VIRL server, then formats the information to feed into the Ansible inventory system.  The output
can be seen by simply running the dynamic inventory script:

``` shell
$ inventory/virl.py
{
    "all": {
        "hosts": [
            "core",
            "vsmart1",
            "~mgmt-lxc",
            "sp1",
            "hq",
            "server1",
            "vbond1",
            "vedge1",
            "host2",
            "host1",
            "internet",
            "vmanage1",
            "service1",
            "vedge-hq",
            "vedge2"
        ],
        "vars": {
            "virl_username": "guest",
            "virl_password": "Cisc0123",
            "virl_host": "cpn-rtp-virl1.ciscops.net"
        }
    },
    "_meta": {
        "hostvars": {
            "core": {
                "ansible_host": "192.133.178.89"
            },
            "vsmart1": {
                "ansible_host": "192.133.178.98"
            },
            "~mgmt-lxc": {
                "ansible_host": "192.133.178.87"
            },
            "sp1": {
                "ansible_host": "192.133.178.92"
            },
            "hq": {
                "ansible_host": "192.133.178.90"
            },
            "server1": {
                "ansible_host": "192.133.178.101"
            },
            "vbond1": {
                "ansible_host": "192.133.178.93"
            },
            "host2": {
                "ansible_host": "192.133.178.100"
            },
            "host1": {
                "ansible_host": "192.133.178.99"
            },
            "internet": {
                "ansible_host": "192.133.178.91"
            },
            "vmanage1": {
                "ansible_host": "192.133.178.97"
            },
            "vedge-hq": {
                "ansible_host": "192.133.178.94"
            },
            "service1": {
                "ansible_host": "192.133.178.102"
            },
            "vedge1": {
                "ansible_host": "192.133.178.95"
            },
            "vedge2": {
                "ansible_host": "192.133.178.96"
            }
        }
    }
}
```
 
The inventory file `inventory/viptela.yml` is used in conjunction with the dynamically retrieved information to classify
the devices into groups (e.g. viptela_control).  Use the `cat` command to view the contents of the file-based inventory:

``` shell
$ cat inventory/viptela.yml
all:
  vars:
    ansible_user: admin
    ansible_password: admin
    ansible_network_os: ios
    netconf_template_os: ios
  children:
    routers:
      hosts:
        internet:
        hq:
        core:
        sp1:
    clients:
      hosts:
        host1:
        host2:
    viptela:
      vars:
        netconf_template_os: viptela
      children:
        viptela_control:
          children:
            vmanage_hosts:
              hosts:
                vmanage1:
            vbond_hosts:
              hosts:
                vbond1:
            vsmart_hosts:
              hosts:
                vsmart1:
        viptela_vedge:
          hosts:
            vedge-hq:
            vedge1:
            vedge2:
```

Finally, this information is augmented with host and group specific information from `group_vars` and `host_vars`:

## Complete

You have completed lab exercise 1.1

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)
