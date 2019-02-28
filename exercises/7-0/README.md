# Exercise 7.0 - Clean up the Topology

#### Step 1

Now that we are done with the workshop, let's clean up the environment:

```shell
ansible-playbook clean.yml
```

This playbook will:
* Remove topology devices from the `known_hosts` file
* Remove the `myCA` directory
* Destroy the topology specified in `.virl/default/id`

## Complete

You have completed lab exercise 7.0

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)