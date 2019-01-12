# Exercise 4.2 - Updating the router configuration with RESTCONF

Using Ansible you can update the configuration of routers either by pushing a configuration file to the device or you can push configuration lines directly to the device.

#### Step 1

Create a new file called `ntp-restconf.yml` with the following play and task to ensure that the NTP servers are present on all the routers.  Use the `uri` module for this task

> Note: For help on the **uri** module, use the **ansible-doc uri** command from the command line or check docs.ansible.com. This will list all possible options with usage examples.

```yaml

---
- name: CONFIGURE ROUTERS
  hosts: routers
  connection: local
  gather_facts: no
  tasks:
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
            server-list:
              - { ip-address: 192.5.41.40 }
              - { ip-address: 192.5.41.41 }
        validate_certs: no
        status_code: [200, 204]
      register: results

    - debug:
        msg: "Status: {{ results.status }}"
```

The uri task does a REST call to the device to set the values with the `PUT` method.  To get more information in the status of the REST call, we print out the result with the `debug` module.

Now let's add another task using the `uri` module with the `GET` method to see what the result was of the previous `PUT`:


```yaml

---
- name: CONFIGURE ROUTERS
  hosts: routers
  connection: local
  gather_facts: no
  tasks:
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
            server-list:
              - { ip-address: 192.5.41.40 }
              - { ip-address: 192.5.41.41 }
        validate_certs: no
        status_code: [200, 204]
      register: results

    - debug:
        msg: "Status: {{ results.status }}"

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

    - debug:
        msg: "NTP Servers: {{ results.json['Cisco-IOS-XE-ntp:server']['server-list'] | map(attribute='ip-address') | join(',') }}"
```

Run the playbook:

``` shell
$ ansible-playbook ntp-restconf.yml

PLAY [CONFIGURE ROUTERS] ***********************************************************************************************************************

TASK [SET THE NTP SERVERS] *********************************************************************************************************************
ok: [internet]
ok: [sp1]
ok: [core]
ok: [hq]

TASK [debug] ***********************************************************************************************************************************
ok: [core] => {
    "msg": "Status: 204"
}
ok: [sp1] => {
    "msg": "Status: 204"
}
ok: [hq] => {
    "msg": "Status: 204"
}
ok: [internet] => {
    "msg": "Status: 204"
}

TASK [GET THE NTP LIST SERVERS] ****************************************************************************************************************
ok: [core]
ok: [internet]
ok: [sp1]
ok: [hq]

TASK [debug] ***********************************************************************************************************************************
ok: [core] => {
    "msg": "NTP Servers: 192.5.41.40,192.5.41.41"
}
ok: [sp1] => {
    "msg": "NTP Servers: 192.5.41.40,192.5.41.41"
}
ok: [hq] => {
    "msg": "NTP Servers: 192.5.41.40,192.5.41.41"
}
ok: [internet] => {
    "msg": "NTP Servers: 192.5.41.40,192.5.41.41"
}

PLAY RECAP *************************************************************************************************************************************
core                       : ok=4    changed=0    unreachable=0    failed=0
hq                         : ok=4    changed=0    unreachable=0    failed=0
internet                   : ok=4    changed=0    unreachable=0    failed=0
sp1                        : ok=4    changed=0    unreachable=0    failed=0
```

Feel free to log in and check the configuration update.

>Note: The **uri** module simply sends the payload via REST for a particular operation.  There is no idempotency in the `uri`
because there is no checking beforehand.  To make these calls idempotent, either the API has to be idempotent or the appriete
checks must be done beforehand.

>Note: We changed to `connection: local` meaning that all tasks in this play will run on the localhost instead of the target
device because the `uri` module must be called on the same host that is running the playbook.

## Complete

You have completed lab exercise 4.2

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)
