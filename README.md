# Nimbus

Nimbus is my "critical loads" kubernetes cluster where I run things that are important for the household. 

The structure of this repo is strongly inspired by [onedr0p/home-ops](https://github.com/onedr0p/home-ops). 

Foundational components:

- Talos
- talhelper
- flux-operator
- external-secrets using the 1Password SDK provider
- metrics-server
- spegel

Bootstrapping is managed with Rake.

License: MIT
