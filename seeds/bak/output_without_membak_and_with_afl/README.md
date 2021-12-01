### memcached-pmem

We remove the following buggy seeds in `out_memcached` due to hang in afl-cov.

- id:000051,src:000011,time:48270,op:havoc,rep:8
- id:000127,src:000106+000005,time:668102,op:splice,rep:2
- id:000152,src:000098+000044,time:1243817,op:splice,rep:4
- id:000166,src:000109+000000,time:1837529,op:splice,rep:2,+cov
- id:000167,src:000109+000000,time:1838745,op:splice,rep:16
- id:000168,src:000109+000000,time:1839406,op:splice,rep:4
- id:000169,src:000109+000000,time:1841844,op:splice,rep:4

The above seeds can be found in `out_memcached-bak`.
