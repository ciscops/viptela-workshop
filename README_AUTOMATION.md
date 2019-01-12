# Viptela Automation Workshop

This is the network automation version of the [Viptela SDX Workshop](README.md).  It is not meant to be an exhaustive treatment
of any of the technologies presented, but an application of those technologies to a real-world use case for automation.  In order
to get the most from this workshop, we recommend these [pre-requisites](devnet_courses.md) from [Cisco DevNet](https://developer.cisco.com/).

## Network Automation Exercises

### Section 01 - Spinning up the Workshop topology in VIRL
- [Exercise 1.0 - Building the topology](./exercises/1-0)
- [Exercise 1.1 - Exploring the workshop environment](./exercises/1-1)

### Section 02 - Using Ansible to gather data from network devices
- [Exercise 2.0 - Writing your first playbook](./exercises/2-0)
- [Exercise 2.1 - Module documentation, Registering output & tags](./exercises/2-1)

### Section 03 - Using Ansible to backup, and restore
- [Exercise 3.0 - Backing up the router configuration](./exercises/3-0)
- [Exercise 3.1 - Restoring the backed up configuration](./exercises/3-1)

### Section 04 - Using Ansible to configure via CLI and NETCONF
- [Exercise 4.0 - Configure the router configurations using CLI](./exercises/4-0)
- [Exercise 4.1 - Configure the router configurations using NETCONF](./exercises/4-1)
- [Exercise 4.2 - Configure the router configurations using RESTCONF](./exercises/4-2)

### Section 05 - An introduction to templating with Jinja2 
- [Exercise 5.0 - An introduction to templating with Jinja2](./exercises/5-0)

### Section 06 - Advanced Concepts
- [Exercise 6.0 - Parsing unstrcutured data with TextFSM](./exercises/6-0)
- [Exercise 6.1 - Adding idempotency to REST](./exercises/6-1)
- [Exercise 6.2 - An introduction to Roles](./exercises/6-2)

### Section 07 - Bring up the Viptela Overlay Network
- [Exercise 7.0 - Bring up the Viptela Control Plane](./exercises/7-0)
- [Exercise 7.1 - Bring up the Viptela Edge](./exercises/7-1)

### Section 08 - Clean up the workshop topoloigy
- [Exercise 8.0 - Clean up the workshop topoloigy](./exercises/8-0)

## Additional information
 - [Network Automation with Ansible Homepage](https://www.ansible.com/network-automation)
 - [List of Networking Ansible Modules](http://docs.ansible.com/ansible/latest/list_of_network_modules.html)
 - [Module Maintenance & Support](http://docs.ansible.com/ansible/latest/modules_support.html)
 - [Network Automation GitHub Repo](https://github.com/network-automation)

---