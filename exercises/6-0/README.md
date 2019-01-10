# Exercise 6.0 - Clean up the Topology
```
ansible-playbook clean.yml
```

This playbook will:
* Remove topology devices from the `known_hosts` file
* Remove the `myCA` directory
* Destroy the topology specified in `.virl/default/id`