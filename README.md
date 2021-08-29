# K3D

## Prerequisites


## Setup

When the cluster is just created:
- applications can be installed right away
- it can take 10 mins before you can access them through the browser while the nginx ingress and cert manager come up.

## Stopping the cluster

```
PROVIDER=k3d make stop
```

## Starting the cluster

```
PROVIDER=k3d make start
```
