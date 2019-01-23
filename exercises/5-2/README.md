# Exercise 5.2 - Configure the Viptela vEdges


Now, provision the vEdges in the topology:

```shell
ansible-playbook configure.yml --tags=vedge
```

This playbook will:
* Push private CA to the vedges
* Bootstrap the vedges
* Add vedges to vmanage
* Check full connectivity

## Complete

You have completed lab exercise 5.2

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)