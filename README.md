## Description

This is a vagrant project to configure a VM for the artifact evaluation of PMRace.

## Prerequisites

### Hardware Requirement

The `Vagrantfile` allocates 16 CPUs and 32 GB DRAM for the VM, which are necessary to enable the concurrent fuzzing in PMRace. Hence, a host machine for the artifact evaluation needs to satisfy the following hardware requirements:

- CPU: >= 16 threads
- DRAM: >= 32 GB
- DISK: ~100 GB

Note that our artifacts can be evaluated without Optane PMem.

### Software Dependencies

Install required dependencies.

```sh
    $ sudo apt-get install virtualbox
    $ sudo apt-get install vagrant
```

## Steps to Install the Artifact

1. Install the [prerequisites](#software-dependencies)

2. Init the VM (~1 hour)

```sh
    $ vagrant up
```

3. Login the VM via ssh

```sh
    $ vagrant ssh
```

4. Build PMRace in the VM (~15 minutes)

```sh
    vagrant@PMRace-AE:~$ ./scripts/build_pmrace.sh
```

To run experiments, please refer to the detailed instructions in [EXPERIMENTS](./EXPERIMENTS.md).
