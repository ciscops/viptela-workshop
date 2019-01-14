# Exercise 7.1 - Configure the Viptela vEdges


The playbook can be run with tags to only perform certain stages.  For example:

```shell
ansible-playbook configure.yml --tags=vedge
```
will only configure the vEdges.  The `check_connectivty` will only check the connectivity of the overlay.

This playbook will:
* Push private CA to the vedges
* Bootstrap the vedges
* Add vedges to vmanage
* Check full connectivity

## Complete

You have completed lab exercise 7.1

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)