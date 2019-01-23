# Exercise 3.0 - Backing up the router configuration


In this realistic scenario,  you will create a playbook to back-up Cisco router configurations. In subsequent labs we will use this backed up configuration, to restore devices to their known good state.

> Note: Since this is a common day 2 operation for most network teams, you can pretty much re-use most of this content for your environment with minimum changes.

#### Step 1

Create a new file called `backup.yml` using your favorite text editor and add the following:

``` yaml

---
- name: BACKUP ROUTER CONFIGURATIONS
  hosts: routers
  connection: network_cli
  gather_facts: no

  tasks:
    - name: BACKUP THE CONFIG
      ios_config:
        backup: yes
      register: config_output
```

The `ios_config` Ansible module is used to back up the configuration of all devices defined in `router` group.

The `backup` parameter automatically creates a directory called `backup` within the playbook root and saves a time-stamped backup of the running configuration.

> Note: Use **ansible-doc ios_config** or check out **docs.ansible.com** for help on the module usage.


Why are we capturing the output of this task into a variable called `config_output`? **Step 2** will reveal this.


Now run the playbook:

``` shell
$ ansible-playbook backup.yml

PLAY [BACKUP ROUTER CONFIGURATIONS] ************************************************************************************************************

TASK [BACKUP THE CONFIG] ***********************************************************************************************************************
ok: [sp1]
ok: [internet]
ok: [hq]
ok: [core]

PLAY RECAP *************************************************************************************************************************************
core                       : ok=1    changed=0    unreachable=0    failed=0
hq                         : ok=1    changed=0    unreachable=0    failed=0
internet                   : ok=1    changed=0    unreachable=0    failed=0
sp1                        : ok=1    changed=0    unreachable=0    failed=0
```


The playbook should now have created a directory called `backup`. Now, list the contents of this directory:


``` shell
$ ls -l backup
total 64
-rw-r--r--  1 stevenca  staff  4844 Jan  9 13:38 core_config.2019-01-09@13:38:05
-rw-r--r--  1 stevenca  staff  5419 Jan  9 13:38 hq_config.2019-01-09@13:38:05
-rw-r--r--  1 stevenca  staff  5353 Jan  9 13:38 internet_config.2019-01-09@13:38:05
-rw-r--r--  1 stevenca  staff  4768 Jan  9 13:38 sp1_config.2019-01-09@13:38:05
```

Feel free to open up these files to validate their content.

#### Step 2

Since we will be using the backed up configurations as a source to restore the configuration. Let's rename them to reflect the device name.

In **Step 1** you captured the output of the task into a variable called `config_output`. This variable contains the name of the backup file. Use the `copy` Ansible module to make a copy of this file.


``` yaml

---
- name: BACKUP ROUTER CONFIGURATIONS
  hosts: routers
  connection: network_cli
  gather_facts: no

  tasks:
    - name: BACKUP THE CONFIG
      ios_config:
        backup: yes
      register: config_output

    - name: RENAME BACKUP
      copy:
        src: "{{config_output.backup_path}}"
        dest: "./backup/{{inventory_hostname}}.config"

```

Re-run the playbook:


``` shell
$ ansible-playbook backup.yml

PLAY [BACKUP ROUTER CONFIGURATIONS] ************************************************************************************************************

TASK [BACKUP THE CONFIG] ***********************************************************************************************************************
ok: [sp1]
ok: [hq]
ok: [core]
ok: [internet]

TASK [RENAME BACKUP] ***************************************************************************************************************************
changed: [sp1]
changed: [core]
changed: [hq]
changed: [internet]

PLAY RECAP *************************************************************************************************************************************
core                       : ok=2    changed=1    unreachable=0    failed=0
hq                         : ok=2    changed=1    unreachable=0    failed=0
internet                   : ok=2    changed=1    unreachable=0    failed=0
sp1                        : ok=2    changed=1    unreachable=0    failed=0
```

Once again list the contents of the `backup` directory:

``` shell
$ ls -l backup
total 128
-rw-r--r--  1 stevenca  staff  4844 Jan  9 13:41 core.config
-rw-r--r--  1 stevenca  staff  4844 Jan  9 13:41 core_config.2019-01-09@13:41:55
-rw-r--r--  1 stevenca  staff  5419 Jan  9 13:41 hq.config
-rw-r--r--  1 stevenca  staff  5419 Jan  9 13:41 hq_config.2019-01-09@13:41:55
-rw-r--r--  1 stevenca  staff  5353 Jan  9 13:41 internet.config
-rw-r--r--  1 stevenca  staff  5353 Jan  9 13:41 internet_config.2019-01-09@13:41:55
-rw-r--r--  1 stevenca  staff  4768 Jan  9 13:41 sp1.config
-rw-r--r--  1 stevenca  staff  4768 Jan  9 13:41 sp1_config.2019-01-09@13:41:55
```

Notice that the directory now has another backed-up configuration but one that reflects the device's name.


#### Step 3

If we were to try and manually restore the contents of this file to the respective device there are two lines in the configuration that will raise errors:

``` shell
Building configuration...

Current configuration with default configurations exposed : 393416 bytes

```
These lines have to be "cleaned up" to have a restorable configuration.

Write a new task using Ansible's `lineinfile` module to remove the first line.


``` yaml

---
- name: BACKUP ROUTER CONFIGURATIONS
  hosts: routers
  connection: network_cli
  gather_facts: no

  tasks:
    - name: BACKUP THE CONFIG
      ios_config:
        backup: yes
      register: config_output

    - name: RENAME BACKUP
      copy:
        src: "{{config_output.backup_path}}"
        dest: "./backup/{{inventory_hostname}}.config"

    - name: REMOVE NON CONFIG LINES
      lineinfile:
        path: "./backup/{{inventory_hostname}}.config"
        line: "Building configuration..."
        state: absent
```


> Note: The module parameter **line** is matching an exact line in the configuration file "Building configuration..."


Before we run the playbook, we need to add one more task to remove the second line "Current configuration ...etc". Since this line has a variable entity (the number of bytes), we cannot use the `line` parameter of the `lineinfile` module. Instead, we'll use the `regexp` parameter to match on regular expressions and remove the line in the file:


``` yaml

---
- name: BACKUP ROUTER CONFIGURATIONS
  hosts: routers
  connection: network_cli
  gather_facts: no

  tasks:
    - name: BACKUP THE CONFIG
      ios_config:
        backup: yes
      register: config_output

    - name: RENAME BACKUP
      copy:
        src: "{{config_output.backup_path}}"
        dest: "./backup/{{inventory_hostname}}.config"

    - name: REMOVE NON CONFIG LINES
      lineinfile:
        path: "./backup/{{inventory_hostname}}.config"
        line: "Building configuration..."
        state: absent

    - name: REMOVE NON CONFIG LINES - REGEXP
      lineinfile:
        path: "./backup/{{inventory_hostname}}.config"
        regexp: 'Current configuration.*'
        state: absent                        
```

Now run the playbook:

``` shell
$ ansible-playbook backup.yml

PLAY [BACKUP ROUTER CONFIGURATIONS] ************************************************************************************************************

TASK [BACKUP THE CONFIG] ***********************************************************************************************************************
ok: [sp1]
ok: [core]
ok: [hq]
ok: [internet]

TASK [RENAME BACKUP] ***************************************************************************************************************************
changed: [core]
changed: [sp1]
changed: [internet]
changed: [hq]

TASK [REMOVE NON CONFIG LINES] *****************************************************************************************************************
changed: [core]
changed: [sp1]
changed: [hq]
changed: [internet]

TASK [REMOVE NON CONFIG LINES - REGEXP] ********************************************************************************************************
changed: [core]
changed: [sp1]
changed: [hq]
changed: [internet]

PLAY RECAP *************************************************************************************************************************************
core                       : ok=4    changed=3    unreachable=0    failed=0
hq                         : ok=4    changed=3    unreachable=0    failed=0
internet                   : ok=4    changed=3    unreachable=0    failed=0
sp1                        : ok=4    changed=3    unreachable=0    failed=0
```


Use an editor to view the cleaned up files. The first 2 lines that we cleaned up in the earlier tasks should be absent:

``` shell
$ head -n 10 backup/core.config

!
! Last configuration change at 18:30:15 UTC Wed Jan 9 2019 by admin
!
version 16.6
service tcp-keepalives-in
service tcp-keepalives-out
service timestamps debug datetime msec
service timestamps log datetime msec
service password-encryption
```

> Note: The **head** unix command will display the first N lines specified as an argument.

## Step 4

Now let's try to apply our knowledge.  Use the Ansible [copy](https://docs.ansible.com/ansible/latest/modules/copy_module.html)
and [file](https://docs.ansible.com/ansible/latest/modules/file_module.html#file-module) modules to rename the backup file to `<router name>.config`
and delete the original.

## Complete

You have completed lab exercise 3.0

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)
