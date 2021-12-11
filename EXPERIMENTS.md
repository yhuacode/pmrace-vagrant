## Description

The following instructions are based on the assumption that experiments (and all commands) are run in the started VM. Please refer to previous [documentation](./README.md) for the VM construction.

## Things Need to Know Before Evaluation

Due to the hardware limits of of VM, experiments 1 and 2 use a small scale of seeds by default. The number of concurrent worker processes for fuzzing is limited to 4 (the paper's results use 13 worker processes). Hence, the performance results and number of inconsistencies may be different.

For the convenience fo artifact evaluation, experiments 1, 2, 3, and 4 use generated seeds stored in `~/seeds`. In experiment 5, the script will automatically generate seeds using different configurations.

## Experiments

### Build All PM Workloads and Tools

1. Build all five PM systems to be tested (~10 minutes)

```sh
    vagrant@PMRace-AE:~$ ./scripts/build_all_workloads.sh
```

2. Build the tools for [afl-cov](https://github.com/mrash/afl-cov) (~5 minutes)

```sh
    vagrant@PMRace-AE:~$ ./scripts/build_afl.sh
```

### Experiment-1: Bug Detection for 5 PM Workloads

In this experiment, the script will try to find the PM concurrency/sequential bugs reported in the paper using PMRace. In order to accelerate the evaluation and reduce the output size, the experiment uses a sample of seeds (`~/seeds/sample` by default) for bug detection and limits the fuzzing time. Hence, you can run this experiment to quickly confirm the success of experimental setup.

The detailed steps are as follows.

1. Run the bug detection for all workloads with default sampled seeds (~45 minutes)

```sh
    vagrant@PMRace-AE:~$ ./scripts/debug_all_workloads.sh
```

2. Count the found unique bugs (few seconds)

```sh
    vagrant@PMRace-AE:~$ ./scripts/exp1_count_found_bugs.sh
```

**Optional Workflow**:

This optional workflow is used to redo the bug detection for a specific PM program without re-run the entire experiment. To debug a single PM program, run the following command

```sh
    vagrant@PMRace-AE:~$ ./scripts/debug_workload.sh WORKLOAD [SCALE]
```

The `WORKLOAD` should be one of `pclht`, `clevel`, `cceh`, `fast_fair`, and `memcached`. The optional `SCALE` should be `sample` (the default value for a small seed scale) or `full`. Check found bugs using the command `./scripts/exp1_count_found_bugs.sh`


**Expected Results**: The end of the output is the statistics of unique bugs found by PMRace (Table 1). A unique bug represents a group of bugs reading non-persisted data, which are written by the same store instruction (i.e., multiple reader instructions but one writer instruction). The summarized bug reports are in corresponding report folders (please refer to the command outputs of `./scripts/exp1_count_found_bugs.sh`) for tested PM workloads.

Note that one of the non-PM concurrency bug (classified as "other bugs" in the paper), i.e., the missing of unlock in `clht_update()`, is not the target of this experiment and is not reproduced. In fact, the bug about unlock missing is easy to manifest in testing. However, in order to get rid of unnecessary hang due to the missing of unlock and facilitate evaluation, we have already fixed the bug in the patch. As a result, the number of "other bugs" for P-CLHT in this experiment is 1 instead of 2.

It is possible to observe different numbers of bugs for some workloads (e.g., FAST-FAIR, memcached-pmem), since only a sample of seeds are tested for limited time (45 minutes for 5 programs in total). Moreover, the thread interleaving is nondeterministic. Trying more times or using more seeds (e.g., `~/seeds/full`) is helpful to find more bugs.

Specifically, instead of running the bug detection for all PM program again, there are two ways to debug a single PM program.

**Option 1** (recommended due to the convenience): Edit `~/scripts/debug_all_workloads.sh` and comment out the workloads to be skipped in next tests. For example, the following edited version of `~/scripts/debug_all_workloads.sh` will only test memcached-pmem using the default sampled seeds for 20 minutes.

```sh
#!/bin/bash

SCRIPT_PATH=/home/vagrant/scripts/debug_workload.sh

# timeout 5m $SCRIPT_PATH pclht sample
# timeout 5m $SCRIPT_PATH clevel sample
# timeout 5m $SCRIPT_PATH cceh sample
# timeout 10m $SCRIPT_PATH fast_fair sample
timeout 20m $SCRIPT_PATH memcached sample
```

Re-run the experiment and check the results

```sh
    vagrant@PMRace-AE:~$ ./scripts/debug_all_workloads.sh
    vagrant@PMRace-AE:~$ ./scripts/exp1_count_found_bugs.sh
```

**Option 2**: Leverage the script `~/scripts/debug_workload.sh` to debug a single PM program. An example to test memcached-pmem using the **full** size of seeds and check the results is as follows


```sh
    vagrant@PMRace-AE:~$ ./scripts/debug_workload.sh memcached full
    vagrant@PMRace-AE:~$ ./scripts/exp1_count_found_bugs.sh
```

Note that there is no time limit in `./scripts/debug_workload.sh`. Hence, you may need to manually stop the execution of `~/scripts/debug_workload.sh` by `CTRL+C`.

### Experiment-2: PM Concurrency Bug Statistics

In this experiment, we investigate the PM concurrency bugs found in the first experiment.

1. Run the post-failure validation for all workloads (~30 minutes)

```sh
    vagrant@PMRace-AE:~$ ./scripts/validate_bugs_in_all_workloads.sh
```

2. Generate the statistics of PM concurrency bugs (few seconds)

```sh
    vagrant@PMRace-AE:~$ ./scripts/exp2_get_con_bug_statistics.sh
```

**Optional Workflow**:

Similar to the workflow of bug detection for a single program, it is possible to validate the bug detection results for one workload at a time.

```sh
    vagrant@PMRace-AE:~$ ./scripts/validate_bugs_in_workload.sh WORKLOAD
```

**Expected Results**: The output of `./scripts/exp2_get_con_bug_statistics.sh` is the PM concurrency bug statistics, which is similar to Table 2 in the paper. Due to the limited seed scale and fuzzing time in the first experiment, the numbers may be relatively small, especially for FAST-FAIR and memcached-pmem. For example, for the statistics about memcached-pmem (an in-memory key-value store), it took us about two days using 13 worker processes for fuzzing. In the artifact evaluation, the first experiment leverages 4 worker processes. Note that each work process debugs a PM concurrent program, which spawns at least 4 threads. Hence, 4 worker processes almost consume all CPU resources of the VM.

### Experiment-3: The Time to Detect PM Inter-thread Inconsistency

Run the bug detection for P-CLHT with different interleaving exploration strategies (~6 hours)

```sh
    vagrant@PMRace-AE:~$ ./scripts/exp3_runtime_inconsistency_graph.sh
```

**Expected Results**: This command will output a graph about the time to find PM inter-thread inconsistencies in P-CLHT (Figure 7a), which is placed in `/home/vagrant/download/results` on the VM (i.e., the `download` folder in `pmrace-vagrant` on the host machine).

Reproducing the performance results of the bug detection on FAST-FAIR and memcached-pmem requires more CPU resources (verified using 104 threads) to simultaneously test more seeds and more fuzzing time to find inconsistencies (6 hours for FAST-FAIR, 30 hours for memcached-pmem). Given appropriate hardware resources, users can edit `~/scripts/exp3_runtime_inconsistency_graph.sh` to enable the performance evaluation of bug detection on FAST-FAIR and memcached-pmem.

### Experiment-4: The Code Coverage of memcached-pmem Commands

Evaluate the code coverage of memcached-pmem using default seeds (~20 minutes)

```sh
    vagrant@PMRace-AE:~$ ./scripts/exp4_memcached_pmem_code_coverage.sh
```

**Expected Results**: The end of command output is the locations of web pages for the code coverage of memcached-pmem. For the detailed numbers about the coverage of memcached commands (Table 3), please refer to the lcov report page for "memcached.c" and check the line data (hit times) for the following lines.

#Line | Commands or Cases
------|------------------
 4639 | `process_command()` entry
 4670 | `get`/`bget`
 4679 | `add`/`set`/`replace`/`prepend`/`append`
 4687 | `incr`
 4695 | `decr`
 4699 | `delete`
 4948 | ERROR (invalid commands)

From the above results, we can learn that a non-negligible part of executions, i.e., the line data of ERROR (line 4948) compared with the `process_command()` entry (line 4639), using seeds generated by AFL++ fail due to invalid command inputs. In contrast, all the seeds generated by PMRace's input generator are valid (the line data for ERROR is 0).


### Experiment-5: The Impact of Checkpoints for Input Generation

This experiment studies the impact of in-memory checkpoint for the fuzzing speed of input generator for PM programs.

Run the following command to evaluate the impact of in-memory checkpoints (~7 hours)

```sh
    vagrant@PMRace-AE:~$ ./scripts/exp5_fuzzing_speed.sh
```

**Expected Results**: The evaluation results corresponding to Figure 8 are presented in the console output. The output folders are `~/pmrace-mutator/output_with*`. For AFL++, the path of seeds in an output folder is `out_*/default/queue`. The corresponding path for seeds generated by PMRace's mutator is `out_*/default/seeds`.
