# Exercise 6.1 - Updating the router configuration with RESTCONF

Using Ansible you can update the configuration of routers either by pushing a configuration file to the device or you can push configuration lines directly to the device.

#### Step 1

Create a new file called `ntp-restconf.yml` with the following play and task to ensure that the NTP servers are present on all the routers.  Use the `uri` module for this task

> Note: For help on the **uri** module, use the **ansible-doc uri** command from the command line or check docs.ansible.com. This will list all possible options with usage examples.

```yaml
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

Now run with `-vvv` to see the original output from the REST call to see how we knew the formatting for the set call:

```shell
<TRUNCATED>
TASK [GET THE NTP LIST SERVERS] ****************************************************************************************************************
task path: /Users/stevenca/Workspaces/viptela-workshop/ntp-restconf.yml:50
<192.133.178.89> ESTABLISH LOCAL CONNECTION FOR USER: stevenca
<192.133.178.89> EXEC /bin/sh -c '( umask 77 && mkdir -p "` echo /tmp/ansible/${USER}/ansible-tmp-1547302555.23-53872026427777 `" && echo ansible-tmp-1547302555.23-53872026427777="` echo /tmp/ansible/${USER}/ansible-tmp-1547302555.23-53872026427777 `" ) && sleep 0'
Using module file /Users/stevenca/venv/netops/lib/python2.7/site-packages/ansible/modules/net_tools/basics/uri.py
<192.133.178.89> PUT /tmp/ansible/stevenca/ansible-local-148625KfXGQ/tmpHeGX1V TO /tmp/ansible/stevenca/ansible-tmp-1547302555.23-53872026427777/AnsiballZ_uri.py
<192.133.178.89> EXEC /bin/sh -c 'chmod u+x /tmp/ansible/stevenca/ansible-tmp-1547302555.23-53872026427777/ /tmp/ansible/stevenca/ansible-tmp-1547302555.23-53872026427777/AnsiballZ_uri.py && sleep 0'
<192.133.178.89> EXEC /bin/sh -c '/usr/bin/python /tmp/ansible/stevenca/ansible-tmp-1547302555.23-53872026427777/AnsiballZ_uri.py && sleep 0'
<192.133.178.89> EXEC /bin/sh -c 'rm -f -r /tmp/ansible/stevenca/ansible-tmp-1547302555.23-53872026427777/ > /dev/null 2>&1 && sleep 0'
ok: [core] => {
    "cache_control": "private, no-cache, must-revalidate, proxy-revalidate",
    "changed": false,
    "connection": "close",
    "content": "{\n  \"Cisco-IOS-XE-ntp:server\": {\n    \"server-list\": [\n      {\n        \"ip-address\": \"192.5.41.40\"\n      },\n      {\n        \"ip-address\": \"192.5.41.41\"\n      }\n    ]\n  }\n}\n",
    "content_type": "application/yang-data+json",
    "cookies": {},
    "cookies_string": "",
    "date": "Sat, 12 Jan 2019 14:15:52 GMT",
    "invocation": {
        "module_args": {
            "attributes": null,
            "backup": null,
            "body": null,
            "body_format": "raw",
            "client_cert": null,
            "client_key": null,
            "content": null,
            "creates": null,
            "delimiter": null,
            "dest": null,
            "directory_mode": null,
            "follow": false,
            "follow_redirects": "safe",
            "force": false,
            "force_basic_auth": false,
            "group": null,
            "headers": {
                "Accept": "application/yang-data+json"
            },
            "http_agent": "ansible-httpget",
            "method": "GET",
            "mode": null,
            "owner": null,
            "password": "VALUE_SPECIFIED_IN_NO_LOG_PARAMETER",
            "regexp": null,
            "remote_src": null,
            "removes": null,
            "return_content": true,
            "selevel": null,
            "serole": null,
            "setype": null,
            "seuser": null,
            "src": null,
            "status_code": [
                200
            ],
            "timeout": 30,
            "unsafe_writes": null,
            "url": "https://192.133.178.89:443/restconf/data/Cisco-IOS-XE-native:native/Cisco-IOS-XE-native:ntp/Cisco-IOS-XE-ntp:server",
            "url_password": "VALUE_SPECIFIED_IN_NO_LOG_PARAMETER",
            "url_username": "VALUE_SPECIFIED_IN_NO_LOG_PARAMETER",
            "use_proxy": true,
            "user": "VALUE_SPECIFIED_IN_NO_LOG_PARAMETER",
            "validate_certs": false
        }
    },
    "json": {
        "Cisco-IOS-XE-ntp:server": {
            "server-list": [
                {
                    "ip-address": "192.5.41.40"
                },
                {
                    "ip-address": "192.5.41.41"
                }
            ]
        }
    },
    "msg": "OK (unknown bytes)",
    "pragma": "no-cache",
    "redirected": false,
    "server": "nginx",
    "status": 200,
    "transfer_encoding": "chunked",
    "url": "https://192.133.178.89:443/restconf/data/Cisco-IOS-XE-native:native/Cisco-IOS-XE-native:ntp/Cisco-IOS-XE-ntp:server"
}
<TRUNCATED>
```

>Note: The **uri** module simply sends the payload via REST for a particular operation.  There is no idempotency in the `uri`
because there is no checking beforehand.  To make these calls idempotent, either the API has to be idempotent or the appropriate
checks must be done beforehand.

>Note: We changed to `connection: local` meaning that all tasks in this play will run on the localhost instead of the target
device because the `uri` module must be called on the same host that is running the playbook.

## Complete

You have completed lab exercise 6.1

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)
