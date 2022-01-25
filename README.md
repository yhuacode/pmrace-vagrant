## Description

This is a vagrant project to configure a VM for the artifact evaluation of [PMRace](https://github.com/yhuacode/pmrace).

## Folder Structure

```
pmrace-vagrant/
├── download/
├── scripts/
│   └── ...
└── seeds/
    ├── corpus
    ├── full
    └── sample
```

- `download`: A synced-folder for sharing files between the VM and the host machine
- `scripts`: Scripts to build the artifact and run experiments
- `seeds`: `sample` (small scale) and `full` (large scale) are pre-generated seeds for previous 4 experiments. `corpus` are the initial seeds for the input generation in experiment 5.

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

2. Clone the project in host machine

```sh
    $ git clone https://github.com/yhuacode/pmrace-vagrant.git
```

3. Init the VM (~1 hour)

```sh
    $ cd pmrace-vagrant
    $ vagrant up
```

4. Login the VM via ssh

```sh
    $ vagrant ssh
```

5. Build PMRace in the VM (~15 minutes)

```sh
    vagrant@PMRace-AE:~$ ./scripts/build_pmrace.sh
```

To run experiments, please refer to the detailed instructions in [EXPERIMENTS](./EXPERIMENTS.md).

## Contact

If you have any problems, please report in the issue page or contact me.

- Zhangyu Chen (chenzy@hust.edu.cn)
