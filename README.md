# Nimbus

Nimbus is my "critical loads" kubernetes cluster where I run things that are important for the household. 

The structure of this repo is strongly inspired by [onedr0p/home-ops](https://github.com/onedr0p/home-ops). 

Foundational components:

- Talos
- talhelper
- flux-operator
- 1password operator
- metrics-server

Bootstrapping is managed with Rake.

## Bootstrapping

```
$ rake talos:apply
$ talosctl bootstrap -n 10.73.95.139
$ kubectl get csr && kubectl certificate approve <node csr>
$ rake bootstrap:apply
```

License: MIT
