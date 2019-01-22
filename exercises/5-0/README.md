# Exercise 5.0 - An introduction to templating with Jinja2

[Jinja2](http://jinja.pocoo.org/docs/2.10/) is a powerful templating engine for Python. There is native integration of Jinja2 with Ansible. Jinja2 allows for manipulating variables and implementing logical constructs. In combination with the Ansible `template` module, the automation engineer has a powerful tool at their disposal to generate live or dynamic reports.


In this lab you will learn how to use the [template](https://docs.ansible.com/ansible/latest/modules/template_module.html) module to pass collected data from devices to a Jinja2 template.
The template module then renders the output as a `markdown` file.


#### Step 1

This time, we'll use a Jinja2 template to create the payload for the `cli_config` task.  First, take a look at the Jinja2
template `ios-ntp-cli.j2`:

```shell
$ cat templates/ios-ntp-cli.j2
{% for server in ntp_servers %}
ntp server {{ server }}
{% endfor %}
```

Notice that it simply iterates over the elements in the `ntp_servers` list and outputs `ntp server {{ server }}` for each server.

Now create a new playbook called `cli-template.yml` and add the following play definition that uses this template into it:

``` yaml
- name: CONFIGURE ROUTERS
  hosts: routers
  gather_facts: no
  connection: network_cli
  vars:
    ntp_servers:
        - 192.5.41.40
        - 192.5.41.41

  tasks:
    - name: ENSURE THAT THE DESIRED NTP SERVERS ARE PRESENT
      cli_config:
        config: "{{ lookup('template', 'ios-ntp-cli.j2') }}"
```

>Note: We are now using the `cli_config` module that is network OS (vendor) agnostic.  It uses the variable `ansible_network_os`
that we've set in the inventory to determine how to talk to the target device.

Finaly, run the playbook:

```bash
$ ansible-playbook cli-template.yml

PLAY [CONFIGURE ROUTERS] ***********************************************************************************************************************

TASK [ENSURE THAT THE DESIRED NTP SERVERS ARE PRESENT] *****************************************************************************************
ok: [sp1]
ok: [hq]
ok: [core]
ok: [internet]

PLAY RECAP *************************************************************************************************************************************
core                       : ok=1    changed=0    unreachable=0    failed=0
hq                         : ok=1    changed=0    unreachable=0    failed=0
internet                   : ok=1    changed=0    unreachable=0    failed=0
sp1                        : ok=1    changed=0    unreachable=0    failed=0
```

>Note: That Ansible automatically looks in the `templates` directory for templates.   

>Note: Run with `-vvv` to see the output from the template being fed into the `cli_config` module.

#### Step 2

Now create a new playbook called `netconf-template.yml` and add the following play definition to it:

``` yaml
- name: CONFIGURE ROUTERS
  hosts: routers
  gather_facts: no
  connection: netconf
  vars:
    ntp_servers:
        - 192.5.41.40
        - 192.5.41.41
        
  tasks:
    - name: ENABLE NETCONF/YANG ON THE ROUTER
      cli_config:
        config: netconf-yang
      connection: network_cli
        
    - name: ENSURE THAT THE DESIRED NTP SERVERS ARE PRESENT
      netconf_rpc:
        rpc: edit-config
        content: "{{ lookup('template', 'ios-ntp-netconf.j2') }}"
```

>Note: We first need to enable NETCONF on the target device using connection type `network_cli`.

Now run the playbook:

```shell
$ ansible-playbook netconf-template.yml

PLAY [CONFIGURE ROUTERS] ***********************************************************************************************************************

TASK [ENABLE NETCONF/YANG ON THE ROUTER] *******************************************************************************************************
ok: [internet]
ok: [core]
ok: [hq]
ok: [sp1]

TASK [ENSURE THAT THE DESIRED NTP SERVERS ARE PRESENT] *****************************************************************************************
ok: [core]
ok: [sp1]
ok: [hq]
ok: [internet]

PLAY RECAP *************************************************************************************************************************************
core                       : ok=2    changed=0    unreachable=0    failed=0
hq                         : ok=2    changed=0    unreachable=0    failed=0
internet                   : ok=2    changed=0    unreachable=0    failed=0
sp1                        : ok=2    changed=0    unreachable=0    failed=0
```

## Complete

You have completed lab exercise 5.0

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)
