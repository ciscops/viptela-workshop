# Exercise 5.1 - Exercising the vManage REST API

Using the Ansible [uri](https://docs.ansible.com/ansible/latest/modules/uri_module.html) module, you can make REST API
calls to vManage to get and set information.  

#### Step 1

Open a new file called `viptela-devices.yml`.  Since the vManage API requires the use of cookies, we first need to authenticate:

```yaml
- hosts: localhost
  gather_facts: no
  tasks:
    - name: Get Cookie
      uri:
        url: "https://{{ hostvars['vmanage1'].ansible_host }}/j_security_check"
        method: POST
        body:
          j_username: "{{ viptela_api_username }}"
          j_password: "{{ viptela_api_password }}"
        body_format: form-urlencoded
        validate_certs: no
      register: login_results
```
>Note: `viptela_api_username` and `viptela_api_password` are set in the inventory

>Note: We are using `hosts: localhost` meaning that all tasks will be run on the local host instead of the remote device

>Note: Because we are running on the local host, we need to get vManage's IP address from the `ansible_host` variable in context of `vmanage1` 

Assuming this first task completes successful, the cookie is set in `uri_results`.  We can then feed that value to the
REST API call to get the list of devices:

```yaml
    - name: Get a list of fabric devices
      uri:
        url: "https://{{ hostvars['vmanage1'].ansible_host }}/dataservice/device"
        method: GET
        headers:
          Cookie: "{{ login_results.set_cookie }}"
        validate_certs: no
      register: uri_results
```

Finally, we find the names of all of devices with a state of `normal` using the map and selectattr jinja2 [filters](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html), then
we print the list with the debug module and join filter:

```yaml
    - set_fact:
        host_list: "{{ uri_results.json.data | selectattr('status', 'equalto', 'normal') | map(attribute='host-name') | list }}"

    - debug:
        msg: "These devices are part of the fabric: {{ host_list | join(',') }}"
```

Now run the playbook:

``` shell
$ ansible-playbook viptela-devices.yml

PLAY [localhost] *******************************************************************************************************************************

TASK [Get Cookie] ******************************************************************************************************************************
ok: [localhost]

TASK [Get a list of fabric devices] ************************************************************************************************************
ok: [localhost]

TASK [set_fact] ********************************************************************************************************************************
ok: [localhost]

TASK [debug] ***********************************************************************************************************************************
ok: [localhost] => {
    "msg": "These devices are part of the fabric: vmanage1,vsmart1,vbond1"
}

PLAY RECAP *************************************************************************************************************************************
localhost                  : ok=4    changed=0    unreachable=0    failed=0
```

>Note: You might need to run the playbook multiple times as the control plane comes up for all devices to have a state
of `normal`

#### Step 2

Let's apply our knowlege.  Use the `-vvv` option to set the JSON reply from the REST API call, then modify the playbook
to just print out the names of all vbonds.  The output should look similar to this:

```bash
$ ansible-playbook viptela-devices.yml

PLAY [localhost] *******************************************************************************************************************************

TASK [Get Cookie] ******************************************************************************************************************************
ok: [localhost]

TASK [Get a list of fabric devices] ************************************************************************************************************
ok: [localhost]

TASK [set_fact] ********************************************************************************************************************************
ok: [localhost]

TASK [debug] ***********************************************************************************************************************************
ok: [localhost] => {
    "msg": "These vbonds are part of the fabric: vbond1"
}

PLAY RECAP *************************************************************************************************************************************
localhost                  : ok=4    changed=0    unreachable=0    failed=0
```

## Complete

You have completed lab exercise 5.1

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)
