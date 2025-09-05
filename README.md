# Nimbus

An ongoing experiment in building yet another Kubernetes cluster.

So far:

- Uses Talos linux as the base
- Bootstrapping and dev environment are both handled with mise-en-place
- GitOps with Flux
- Networking handled with Cilium, Multus, and Tailscale
- Storage with local-path-provisioner
- Secrets with 1Password Operator in Service Account mode

## Environment Setup

1. Clone this repo
2. Add `GITHUB_API_TOKEN=the_token_value` to the file `.env` in the project root directory
4. Run `mise up`

## Bootstrapping

1. Boot a machine with a Talos ISO. The specfic version doesn't matter all that much.
2. Update `talos/talconfig.yaml` with the specific machine information. IP, any necessary system extensions
3. Run `mise run talos:wait_for_node_csr`
4. Run `mise run bootstrap`

The bootstrapping process will

1. bring the initial node online
2. install an initial set of CRDs necessary for the next step
2. install an initial set of applications: Cilium, 1Password, and Flux

## Webhook

Bootstrap creates a `LoadBalancer` service `nimbus-flux-webhook` that points at `generic-receiver`.
To generate the webhook URL, get the IP address from `nimbus-flux-webhook` and append the path found in the `generic-receiver` status:

```
$ kubectl get service nimbus-flux-webhook -n flux-system
NAME                  TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
nimbus-flux-webhook   LoadBalancer   10.97.121.203   <some ip>     80:31371/TCP   13m
$ kubectl get receiver generic-receiver -n flux-system
NAMESPACE     NAME               AGE   READY   STATUS
flux-system   generic-receiver   12m   True    Receiver initialized for path: /hook/<some long path>
```

The resulting webhook URL is `http://<some ip>/hook/<some long path>`. Set this in the `soft-serve` git server sitting outside of the cluster.

## Repository Structure

Flux is initially configured in `kubernetes/apps/flux-system/flux-instance/helmrelease.yaml`.
The `sync` value points at the git repo URL and the path within the repo to find the initial resources to load, `kubernetes/flux/cluster/ks.yaml`.

That initial `ks.yaml` contains a `Kustomization` resource that points at `kubernetes/apps`.
From there, Flux will search the top level directories for `kustomization.yaml` files.
Each directory represents a kubernetes namespace.
Within those namespaces are `kustomization.yaml` files that require `ks.yaml` files each defining a `Kustomization` resource.
By convention each `Kustomization` points at path like `kubernetes/apps/<namespace>/<app_name>/app`.

## Adding More Nodes

To add more nodes, add them to `talos/talconfig.yaml` and run `mise run talos:apply`.

## Upgrades

TBD!
