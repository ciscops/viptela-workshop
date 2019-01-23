# Viptela Automation Workshop

This is the network automation version of the [Viptela SDX Workshop](README.md).  It is not meant to be an exhaustive treatment
of any of the technologies presented, but an application of those technologies to a real-world use case for automation.  In order
to get the most from this workshop, we recommend these [pre-requisites](pre-requisites.md) from [Cisco DevNet](https://developer.cisco.com/).

## Network Automation Exercises

### Section 01 - Spinning up the Workshop topology in VIRL
- [Exercise 1.0 - Building the topology](./exercises/1-0)
- [Exercise 1.1 - Exploring the workshop environment](./exercises/1-1)

### Section 02 - Using Ansible to gather facts from network devices
- [Exercise 2.0 - Writing your first playbook](./exercises/2-0)
- [Exercise 2.1 - Module documentation, Registering output & tags](./exercises/2-1)

### Section 03 - Using Ansible to backup, and restore
- [Exercise 3.0 - Backing up the router configuration](./exercises/3-0)
- [Exercise 3.1 - Restoring the backed up configuration](./exercises/3-1)

### Section 04 - Using Ansible to configure via CLI
- [Exercise 4.0 - Configure the router configurations using CLI](./exercises/4-0)

### Section 05 - Bring up the Viptela Overlay Network
- [Exercise 5.0 - Bring up the Viptela Control Plane](./exercises/5-0)
- [Exercise 5.1 - Exercising the vManage REST API](./exercises/5-1)
- [Exercise 5.2 - Bring up the Viptela Edge](./exercises/5-2)

### Section 06 - Advanced Concepts
- [Exercise 6.0 - Configure the router configurations using NETCONF](./exercises/6-0)
- [Exercise 6.1 - Configure the router configurations using RESTCONF](./exercises/6-1)
- [Exercise 6.2 - An introduction to templating with Jinja2](./exercises/6-2)
- [Exercise 6.3 - Parsing unstructured data with TextFSM](./exercises/6-3)
- [Exercise 6.4 - Adding idempotency to REST operations](./exercises/6-4)
- [Exercise 6.5 - An introduction to Roles](./exercises/6-5)

### Section 07 - Clean up the workshop topology
- [Exercise 7.0 - Clean up the workshop topology](./exercises/7-0)

## Additional information
 - [Network Automation with Ansible Homepage](https://www.ansible.com/network-automation)
 - [List of Networking Ansible Modules](http://docs.ansible.com/ansible/latest/list_of_network_modules.html)
 - [Module Maintenance & Support](http://docs.ansible.com/ansible/latest/modules_support.html)

---