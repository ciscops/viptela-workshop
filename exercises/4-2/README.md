# Exercise 4.2 - An introduction to templating with Jinja2

[Jinja2](http://jinja.pocoo.org/docs/2.10/) is a powerful templating engine for Python. There is native integration of Jinja2 with Ansible. Jinja2 allows for manipulating variables and implementing logical constructs. In combination with the Ansible `template` module, the automation engineer has a powerful tool at their disposal to generate live or dynamic reports.


In this lab you will learn how to use the `template` module to pass collected data from devices to a Jinja2 template.
The template module then renders the output as a `markdown` file.


#### Step 1

Create a new playbook called `cli-template.yml` and add the following play definition to it:

``` yaml

---
- name: CONFIGURE ROUTERS
  hosts: routers
  gather_facts: no
  connection: network_cli

  tasks:
    - name: ENSURE THAT THE DESIRED NTP SERVERS ARE PRESENT
      cli_config:
        config: "{{ lookup('template', 'ios-ntp-cli.j2') }}"
```

Now run the playbook:

```bash
$ ansible-playbook cli-tempate.yml

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

#### Step 2

Now create a new playbook called `netconf-template.yml` and add the following play definition to it:

``` yaml

---
- name: CONFIGURE ROUTERS
  hosts: routers
  gather_facts: no
  connection: netconf

  tasks:
    - name: ENSURE THAT THE DESIRED NTP SERVERS ARE PRESENT
      netconf_rpc:
        rpc: edit-config
        content: "{{ lookup('template', 'ios-ntp-netconf.j2') }}"
```

Now run the playbook:

```shell
$ ansible-playbook netconf-tempate.yml

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

## Complete

You have completed lab exercise 4.2

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)
