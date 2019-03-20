## Workshop Requirements

### PIP

You need an environment capable of running PIP or the ability to manually install the requirements enumerated in `requirements.txt`
```
pip install -r requirements.txt
```
### SSHPASS


[SSHPass](http://www.cyberciti.biz/faq/noninteractive-shell-script-ssh-password-provider/) is a tiny utility, which allows you to provide the ssh password without using the prompt. This will very helpful for scripting. SSHPass is not good to use in multi-user environment. If you use SSHPass on your development machine, it don't do anything evil.

#### Installing on Ubuntu

```bash
sudo apt-get install sshpass
```
    
#### Installing on RHEL/CentOS

```bash
sudo yum install sshpass
```
    
#### Installing on OS X

Installing on OS X is tricky, since there is no official build for it. Before you get started, you need [install xcode and command line tools](http://guide.macports.org/chunked/installing.xcode.html).

##### Installing with Homebrew

[Homebrew](http://brew.sh/) does not allow you to install `sshpass` by default. But you can use the following unofficial brew package for that.

```bash
brew install https://raw.githubusercontent.com/ciscops/viptela-workshop/master/sshpass.rb
```
      
#### Installing from the Source

* Download the [Source Code](http://sourceforge.net/projects/sshpass/)
* Extract it and cd into the directory
* `./configure`
* `sudo make install`

#### Installing on Windows
Windows does not support python or Ansible suffiently to undertake this lab.  Please install either a Red Hat/CentOS or Unbuntu VM (e.g. with Vagrant) to satisfy the requirements.

### The following DevNet courses:

#### Required:
* [Intro to Ansible for IOS XE ](https://learninglabs.cisco.com/modules/intro-ansible-iosxe/ansible-overview/step/1)
* [Ansible IOS native modules](https://learninglabs.cisco.com/modules/intro-ansible-iosxe/ansible-ios-modules/step/1)
* [Ansible NETCONF modules with IOS XE routers](https://learninglabs.cisco.com/modules/intro-ansible-iosxe/ansible-netconf/step/1)
* [Intro to Ansible for IOS XE - Mission](https://learninglabs.cisco.com/modules/intro-ansible-iosxe/ansible-mission/step/1)
* [Introduction to Cisco SD-WAN REST APIs ](https://learninglabs.cisco.com/modules/sd-wan/intro-sd-wan-rest-api/step/1)

#### Encouraged:
* [Python libraries (pip) and virtual environments](https://learninglabs.cisco.com/modules/home-lab-desktop/02-pip-ve-02-home-lab-pip-virtual-environment/step/1)
* [Introduction to Configuration Management](https://learninglabs.cisco.com/modules/sdx-ansible-intro/ansible-01_config-mgmt-intro/step/1)
* [Using Postman to interact with the Cisco SD-WAN REST API](https://learninglabs.cisco.com/modules/sd-wan/sd-wan-rest-api-postman/step/1)
* [SD-WAN automation with Ansible ](https://learninglabs.cisco.com/modules/sd-wan/sdwan_automation_with_ansible/step/1)
