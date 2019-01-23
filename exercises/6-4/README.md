# Exercise 6.4 - Adding idempotency to REST operations

We saw earlier that when using the `uri` module directly to make REST calls, the idempotency comes from the API, not the `uri`
module itself.  Therefore, if the API is not idempotent, the playbook will not be idempotent.  In the excercise, we will
look at how to add idempotency when the API does not provide it.

#### Step 1

Create a new file called `ntp-restconf2.yml` that perfoms a REST `GET` operation to get the current list of NTP servers:

> Note: For help on the **uri** module, use the **ansible-doc uri** command from the command line or check docs.ansible.com. This will list all possible options with usage examples.

```yaml
- name: CONFIGURE ROUTERS
  hosts: routers
  connection: local
  gather_facts: no
  vars:
    ntp_server_list:
      - { ip-address: 1.1.1.1 }
      - { ip-address: 2.2.2.2 }
  tasks:
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
```

>Note: We've changed the list of NTP servers to a var at the top of the play since we'll be using it in several places.
In practice, however, you'll want to set vars in the inventory to make the playbook re-usable across environments.

>Note: The REST call returns a list of hashes.  Since we want to use [Ansible Filters](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html)
to compare the actual NTP configuration to the desired NTP configuration, which takes a simple list.  To convert, we
use the Jinja2 [map](http://jinja.pocoo.org/docs/dev/templates/#map) filter that Ansible makes available to us.

Run the playbook:
```shell
$ ansible-playbook ntp-restconf2.yml

PLAY [CONFIGURE ROUTERS] ***********************************************************************************************************************

TASK [GET THE NTP LIST SERVERS] ****************************************************************************************************************
ok: [sp1]
ok: [internet]
ok: [core]
ok: [hq]

TASK [set_fact] ********************************************************************************************************************************
ok: [core]
ok: [sp1]
ok: [hq]
ok: [internet]

TASK [debug] ***********************************************************************************************************************************
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

PLAY RECAP *************************************************************************************************************************************
core                       : ok=3    changed=0    unreachable=0    failed=0
hq                         : ok=3    changed=0    unreachable=0    failed=0
internet                   : ok=3    changed=0    unreachable=0    failed=0
sp1                        : ok=3    changed=0    unreachable=0    failed=0
```

>Note: The debug printed out NULL lists, indicating that there is no difference in actual list of NTP servers from the 
desired list of NTP servers.  Choose different values in `ntp_server_list` to see this result change.

Now let's add a conditional the REST `PUT` operation using the Ansible `when` clause that only performs the operation when
there is a difference.  We set another Ansible clause, `changed_when`, to `yes` so that it always show a change when that
task is run.

The uri task does a REST call to the device to set the values with the `PUT` method.  To get more information in the status
of the REST call, we print out the result with the `debug` module.

Now let's add another task using the `uri` module with the `GET` method to see what the result was of the previous `PUT`:

>Note: Refer to the [Programmability Configuration Guide, Cisco IOS XE Everest 16.6.x](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/prog/configuration/166/b_166_programmability_cg/restconf_prog_int.html) for more information

```yaml
- name: CONFIGURE ROUTERS
  hosts: routers
  connection: local
  gather_facts: no
  vars:
    ntp_server_list:
      - { ip-address: 1.1.1.1 }
      - { ip-address: 2.2.2.2 }
  tasks:
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

Run the playbook:

``` shell
$ ansible-playbook ntp-restconf2.yml

PLAY [CONFIGURE ROUTERS] ***********************************************************************************************************************

TASK [GET THE NTP LIST SERVERS] ****************************************************************************************************************
ok: [sp1]
ok: [hq]
ok: [internet]
ok: [core]

TASK [set_fact] ********************************************************************************************************************************
ok: [core]
ok: [sp1]
ok: [hq]
ok: [internet]

TASK [debug] ***********************************************************************************************************************************
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

TASK [SET THE NTP SERVERS] *********************************************************************************************************************
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

Finally, replace the server `2.2.2.2` with `3.3.3.3` in the ntp_server_list and run the playbook again:

```shell
$ ansible-playbook ntp-restconf2.yml

PLAY [CONFIGURE ROUTERS] ***********************************************************************************************************************

TASK [GET THE NTP LIST SERVERS] ****************************************************************************************************************
ok: [hq]
ok: [internet]
ok: [sp1]
ok: [core]

TASK [set_fact] ********************************************************************************************************************************
ok: [core]
ok: [sp1]
ok: [hq]
ok: [internet]

TASK [debug] ***********************************************************************************************************************************
ok: [core] => {
    "msg": [
        "3.3.3.3"
    ]
}
ok: [sp1] => {
    "msg": [
        "3.3.3.3"
    ]
}
ok: [hq] => {
    "msg": [
        "3.3.3.3"
    ]
}
ok: [internet] => {
    "msg": [
        "3.3.3.3"
    ]
}

TASK [SET THE NTP SERVERS] *********************************************************************************************************************
changed: [core]
changed: [sp1]
changed: [internet]
changed: [hq]

PLAY RECAP *************************************************************************************************************************************
core                       : ok=4    changed=1    unreachable=0    failed=0
hq                         : ok=4    changed=1    unreachable=0    failed=0
internet                   : ok=4    changed=1    unreachable=0    failed=0
sp1                        : ok=4    changed=1    unreachable=0    failed=0
```

As you can see, it executed the `PUT` task to make the changes and returned a status of `changed`.  If this playbook
were run again with no changes in the `ntp_server_list`, it would skip the `PUT` task and return a status of `ok`.

## Complete

You have completed lab exercise 6.4

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)
