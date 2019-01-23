# Exercise 6.5 - An introduction to Roles

While it is possible to write a playbook in one file as we've done throughout this workshop, eventually you’ll want to reuse files and start to organize things.

Ansible Roles is the way we do this.  When you create a role, you deconstruct your playbook into parts and those parts sit in a directory structure.  

For this exercise, you are going to take the playbook you just wrote and refactor it into a role.  In addition, you'll learn to use Ansible Galaxy.


## Section 1: Using Ansible Galaxy to initialize a new role

Ansible Galaxy is a free site for finding, downloading, and sharing roles.  It's also pretty handy for creating them which is what we are about to do here.


### Step 1:

Navigate to the `roles` directory in the project.
 
>Note: In a previous exercise, we specified in `ansible.cfg` that roles should be at the level of the main project instead
of at the level of the playbook, which is the default. 

```bash
cd roles
```

### Step 2:

Use the `ansible-galaxy` command to initialize a new role called `ios-ntp`.

```bash
ansible-galaxy init ios-ntp
```

Take a look around the structure you just created.  Here are a few commonly used directories:

* The Role entry point is `roles/ios-ntp/tasks/main.yml`
* Default variables to your role in `roles/ios-ntp/defaults/main.yml`
* Role-specific variables to your role in `roles/ios-ntp/vars/main.yml`
* Role handlers in `roles/ios-ntp/handlers/main.yml`

## Section 2: Breaking Your `site.yml` Playbook into the Newly Created `ios-ntp` Role


In this section, we will separate out the major parts of your playbook including `vars:`, `tasks:`, `template:`, and `handlers:`.

### Step 1:

```bash
cd ..
cp ntp-restconf2.yml roles/ios-ntp/tasks/main.yml
```

### Step 2:

Now edit `roles/ios-ntp/tasks/main.yml` to remove the play definition and reduce the indentation:

```yaml
- name: GET THE NTP LIST SERVERS
  uri:
    url: "https://{{ hostvars[inventory_hostname].ansible_host }}:443/restconf/data/Cisco-IOS-XE-native:native/Cisco-IOS-XE-native:ntp/Cisco-IOS-XE-ntp:server"
    user: admin
    password: admin
    method: GET
    return_content: yes
    headers:
      Accept: 'application/yang-data+json'
    validate_certs: no
  register: results

- set_fact:
    actual_ntp_servers: "{{ results.json['Cisco-IOS-XE-ntp:server']['server-list'] | map(attribute='ip-address') | list }}"
    desired_ntp_servers: "{{ ntp_server_list | map(attribute='ip-address') | list }}"

- debug:
    msg: "{{ actual_ntp_servers | difference(desired_ntp_servers) }}"

- name: SET THE NTP SERVERS
  uri:
    url: "https://{{ hostvars[inventory_hostname].ansible_host }}:443/restconf/data/Cisco-IOS-XE-native:native/Cisco-IOS-XE-native:ntp/Cisco-IOS-XE-ntp:server"
    user: admin
    password: admin
    method: PUT
    return_content: yes
    headers:
      Content-Type: 'application/yang-data+json'
      Accept: 'application/yang-data+json, application/yang-data.errors+json'
    body_format: json
    body:
      server:
        server-list: "{{ ntp_server_list }}"
    validate_certs: no
    status_code: [200, 204]
  register: results
  changed_when: yes
  when: actual_ntp_servers != desired_ntp_servers
```

### Step 3:

We are going to put the default variables into `roles/ios-ntp/defaults/main.yml` so they can be overridden by either passing
in vars with the role or with host_vars/group_vars:

```yml
# defaults file for ios-ntp
ntp_server_list:
  - { ip-address: 192.5.41.40 }
  - { ip-address: 192.5.41.41 }
```

>Note: The following variable precedence:
>
>- vars directory
>- defaults directory
>- group_vars directory
>- In the playbook under the `vars:` section
>- In any file which can be specified on the command line using the `--extra_vars` option
>- On a boat, in a moat, with a goat  _(disclaimer:  this is a complete lie)_
>
>Refer to [variable precedence](http://docs.ansible.com/ansible/latest/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable) to understand both where to define variables and which locations take precedence.  In this exercise, we are using role defaults to define a couple of variables and these are the most malleable. 



## Section 3: Running your new role-based playbook

### Step 1

Now let's change the original playbook to call the role:

```yaml
- name: CONFIGURE ROUTERS
  hosts: routers
  connection: local
  gather_facts: no
  tasks:
    - include_role:
        name: ios-ntp
```

>Note: We are using `include_role` to call the role instead of the more traditional practice of calling roles in the `roles:`
section of the play.  It is the opinion of the author that this function-like approach makes it easier to intersperse
roles with other logic, making it more conducive to the more complex task of network automation.

Run the playbook.

```bash
ansible-playbook ntp-role.yml
```

If successful, your standard output should look similar to the previous, but with tasks prepended with the role name:

```shell
$ ansible-playbook ntp-role.yml

PLAY [CONFIGURE ROUTERS] ***********************************************************************************************************************

TASK [include_role : ios-ntp] ******************************************************************************************************************

TASK [ios-ntp : GET THE NTP LIST SERVERS] ******************************************************************************************************
ok: [sp1]
ok: [core]
ok: [hq]
ok: [internet]

TASK [ios-ntp : set_fact] **********************************************************************************************************************
ok: [core]
ok: [sp1]
ok: [hq]
ok: [internet]

TASK [ios-ntp : debug] *************************************************************************************************************************
ok: [core] => {
    "msg": []
}
ok: [sp1] => {
    "msg": []
}
ok: [hq] => {
    "msg": []
}
ok: [internet] => {
    "msg": []
}

TASK [ios-ntp : SET THE NTP SERVERS] ***********************************************************************************************************
skipping: [core]
skipping: [sp1]
skipping: [hq]
skipping: [internet]

PLAY RECAP *************************************************************************************************************************************
core                       : ok=3    changed=0    unreachable=0    failed=0
hq                         : ok=3    changed=0    unreachable=0    failed=0
internet                   : ok=3    changed=0    unreachable=0    failed=0
sp1                        : ok=3    changed=0    unreachable=0    failed=0
```

### Step 2

Now, let try to pass in variables to override the default:

```yaml
- name: CONFIGURE ROUTERS
  hosts: routers
  connection: local
  gather_facts: no
  tasks:
    - include_role:
        name: ios-ntp
      vars:
        ntp_server_list:
          - { ip-address: 192.5.41.40 }
          - { ip-address: 192.5.41.43 }
```

Since we changed the NTP servers from the default, we should see a change from the idempotency we added earlier:

```shell
$ ansible-playbook ntp-role.yml

PLAY [CONFIGURE ROUTERS] ***********************************************************************************************************************

TASK [include_role : ios-ntp] ******************************************************************************************************************

TASK [ios-ntp : GET THE NTP LIST SERVERS] ******************************************************************************************************
ok: [hq]
ok: [core]
ok: [internet]
ok: [sp1]

TASK [ios-ntp : set_fact] **********************************************************************************************************************
ok: [core]
ok: [sp1]
ok: [hq]
ok: [internet]

TASK [ios-ntp : debug] *************************************************************************************************************************
ok: [core] => {
    "msg": [
        "192.5.41.41"
    ]
}
ok: [sp1] => {
    "msg": [
        "192.5.41.41"
    ]
}
ok: [hq] => {
    "msg": [
        "192.5.41.41"
    ]
}
ok: [internet] => {
    "msg": [
        "192.5.41.41"
    ]
}

TASK [ios-ntp : SET THE NTP SERVERS] ***********************************************************************************************************
changed: [core]
changed: [sp1]
changed: [hq]
changed: [internet]

PLAY RECAP *************************************************************************************************************************************
core                       : ok=4    changed=1    unreachable=0    failed=0
hq                         : ok=4    changed=1    unreachable=0    failed=0
internet                   : ok=4    changed=1    unreachable=0    failed=0
sp1                        : ok=4    changed=1    unreachable=0    failed=0
```

## Complete

You have completed lab exercise 6.5

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)
