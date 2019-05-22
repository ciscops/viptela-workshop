# Exercise 1.0 -  Using Ansible with Viptela SDx Workshop

## Step1

Cloning the workshop repo repo:

``` shell
git clone https://github.com/ciscops/viptela-workshop.git --recursive
```

## Step 2

Navigate to the `viptela-workshop` directory.

``` shell
$ cd viptela-workshop/
```

>Note: All subsequent exercises will be in this directory unless otherwise noted.

## Step 3

Install requirements with pip:

```
pip install -r requirements.txt
```

Install sshpass (see [pre-requisites](../../pre-requisites.md)).

## Step 4

Deploy Topology:

Create a file named `.virlrc` in the `viptela-workshop` directory:
``` shell
VIRL_USERNAME=guest
VIRL_PASSWORD=guest
VIRL_HOST=your.virl.server
```

>Note: your values will be different.

Run the `build` playbook to the build the topology in `viptela1_csr.virl`:
``` shell
ansible-playbook build.yml
```

>Note: The username is used in the session ID by default.  A different tag can be specified by adding `-e virl_tag=<tag name>`.

This playbook will:
* Launch the topology file
* Wait until they show as reachable in VIRL


## Complete

You have completed lab exercise 1.0

[Click Here to return to the Viptela Networking Automation Workshop](../../README_AUTOMATION.md)
