# Exercise 3.1 - Using Ansible to restore the backed up configuration


In the previous lab you learned how to backup the configuration of the 4 cisco routers. In this lab you will learn how to restore the configuration. The backups had been saved into a local directory called `backup`.


```
backup
├── core.config
├── core_config.2019-01-09@13:51:16
├── hq.config
├── hq_config.2019-01-09@13:51:16
├── internet.config
├── internet_config.2019-01-09@13:51:16
├── sp1.config
└── sp1_config.2019-01-09@13:51:16
```


Our objective is to apply this "last known good configuraion backup" to the routers.

#### Step 1

On one of the routers (`core`) manually make a change. For instance add a new loopback interface.

>Note: to get the listing of the devices in your topology and their associated management IP address, run `virl nodes` in the `viptela-workshop` directory.  The default credentials are admin/admin.

Log into `core` and add the following:

```
core#config terminal
Enter configuration commands, one per line.  End with CNTL/Z.
core(config)#interface loopback 101
core(config-if)#ip address 169.1.1.1 255.255.255.255
core(config-if)#end
```

Now verify the newly created Loopback Interface

```
core#sh run interface loopback 101
Building configuration...

Current configuration : 67 bytes
!
interface Loopback101
 ip address 169.1.1.1 255.255.255.255
end
```

#### Step 2

Step 1 simulates our "Out of process/band" changes on the network. This change needs to be reverted. So let's write a new playbook to apply the backup we collected from our previous lab to achieve this.

Create a playbook called `restore_config.yml` with a task to copy over the previously backed up configuration file to the routers:


``` yaml

---
- name: RESTORE CONFIGURATION
  hosts: routers
  connection: network_cli
  gather_facts: no

  tasks:
    - name: ENABLE SCP ON THE ROUTER
      ios_config:
        lines:
          - ip scp server enable

    - name: COPY RUNNING CONFIG TO ROUTER
      net_put:
        src: ./backup/{{inventory_hostname}}.config
        dest: "bootflash:/{{inventory_hostname}}.config"
```

> Note the use of the **inventory_hostname** variable. For each device in the inventory file under the cisco group, this task will secure copy (scp) over the file that corresponds to the device name onto the bootflash: of the CSR devices.

Now run the playbook:

```
$ ansible-playbook restore_config.yml

PLAY [RESTORE CONFIGURATION] *******************************************************************************************************************

TASK [ENABLE SCP ON THE ROUTER] ****************************************************************************************************************
changed: [core]
changed: [hq]
changed: [internet]
changed: [sp1]

TASK [COPY RUNNING CONFIG TO ROUTER] ***********************************************************************************************************
changed: [core]
changed: [sp1]
changed: [internet]
changed: [hq]

PLAY RECAP *************************************************************************************************************************************
core                       : ok=2    changed=2    unreachable=0    failed=0
hq                         : ok=2    changed=2    unreachable=0    failed=0
internet                   : ok=2    changed=2    unreachable=0    failed=0
sp1                        : ok=2    changed=2    unreachable=0    failed=0
```


#### Step 5

Log into `core` and add do a directory listing:

> Note **core.config** at the bottom of the bootflash:/ directory

```
core#dir
Directory of bootflash:/

   11  drwx            16384  Sep 21 2017 14:26:24 +00:00  lost+found
873121  drwx             4096  Sep 21 2017 14:27:06 +00:00  .super.iso.dir
554881  drwx             4096  Sep 21 2017 14:27:01 +00:00  .installer
   12  -rw-               31   Jan 9 2019 11:36:47 +00:00  .CsrLxc_LastInstall
   13  -rw-               69   Jan 9 2019 11:36:48 +00:00  virtual-instance.conf
905761  drwx             4096   Jan 9 2019 11:35:43 +00:00  core
   15  -rw-        125696000  Sep 21 2017 14:27:06 +00:00  iosxe-remote-mgmt.16.06.01.ova
938403  -rw-        369701848  Sep 21 2017 14:27:27 +00:00  csr1000v-mono-universalk9.16.06.01.SPA.pkg
938404  -rw-         40067508  Sep 21 2017 14:27:35 +00:00  csr1000v-rpboot.16.06.01.SPA.pkg
938402  -rw-             2787  Sep 21 2017 14:27:35 +00:00  packages.conf
416161  drwx             4096   Jan 9 2019 11:35:37 +00:00  .prst_sync
375361  drwx             4096   Jan 9 2019 11:35:44 +00:00  .rollback_timer
807841  drwx             4096   Jan 9 2019 11:36:54 +00:00  virtual-instance
   16  -rw-               30   Jan 9 2019 11:36:38 +00:00  throughput_monitor_params
   17  -rw-             8779   Jan 9 2019 11:36:57 +00:00  cvac.log
   18  -rw-               16   Jan 9 2019 11:36:47 +00:00  ovf-env.xml.md5
   19  -rw-               16   Jan 9 2019 11:36:47 +00:00  .cvac_skip_once
   20  -rw-             1707   Jan 9 2019 11:36:58 +00:00  csrlxc-cfg.log
636481  drwx             4096   Jan 9 2019 11:36:56 +00:00  onep
   14  -rw-             4783   Jan 9 2019 19:34:47 +00:00  core.config

16420106240 bytes total (14520115200 bytes free)
```


#### Step 6

Now that the known good configuration is on the destination devices, add a new task to the playbook to replace the running configuration with the one we copied over.


``` yaml

---
- name: RESTORE CONFIGURATION
  hosts: routers
  connection: network_cli
  gather_facts: no

  tasks:
    - name: ENABLE SCP ON THE ROUTER
      ios_config:
        lines:
          - ip scp server enable

    - name: COPY RUNNING CONFIG TO ROUTER
      net_put:
        src: ./backup/{{inventory_hostname}}.config
        dest: "bootflash:/{{inventory_hostname}}.config"

    - name: CONFIG REPLACE
      ios_command:
        commands:
          - config replace flash:{{inventory_hostname}}.config force
```


> Note: Here we take advantage of Cisco's **archive** feature. The config replace will only update the differences to the router and not really a full config replace.


Let's run the updated playbook:

```
$ ansible-playbook restore_config.yml

PLAY [RESTORE CONFIGURATION] *******************************************************************************************************************

TASK [ENABLE SCP ON THE ROUTER] ****************************************************************************************************************
changed: [hq]
changed: [core]
changed: [internet]
changed: [sp1]

TASK [COPY RUNNING CONFIG TO ROUTER] ***********************************************************************************************************
ok: [sp1]
ok: [core]
ok: [hq]
ok: [internet]

TASK [CONFIG REPLACE] **************************************************************************************************************************
ok: [internet]
ok: [sp1]
ok: [core]
ok: [hq]

PLAY RECAP *************************************************************************************************************************************
core                       : ok=3    changed=1    unreachable=0    failed=0
hq                         : ok=3    changed=1    unreachable=0    failed=0
internet                   : ok=3    changed=1    unreachable=0    failed=0
sp1                        : ok=3    changed=1    unreachable=0    failed=0
```


#### Step 8

Validate that the new loopback interface we added in **Step 1**  is no longer on the device.

```
core#show ip int brief
Interface              IP-Address      OK? Method Status                Protocol
GigabitEthernet1       192.133.178.89  YES DHCP   up                    up
GigabitEthernet2       10.0.255.2      YES TFTP   up                    up
GigabitEthernet3       10.0.1.1        YES TFTP   up                    up
GigabitEthernet4       10.0.255.5      YES TFTP   up                    up
```

The output above shows that the Loopback 101 interface is no longer present, you have successfully backed up and restored configurations on your Cisco routers!

## Complete

You have completed lab exercise 3.1

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)
