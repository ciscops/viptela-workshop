# Configure the Viptela vEdges


The playbook can be run with tags to only perform certain stages.  For example:

```
ansible-playbook configure.yml --tags=vedge
```
will only configure the vEdges.  The `check_connectivty` will only check the connectivity of the overlay.

This playbook will:
* Push private CA to the vedges
* Bootstrap the vedges
* Add vedges to vmanage
* Check full connectivity