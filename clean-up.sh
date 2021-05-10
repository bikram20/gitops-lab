#!/usr/bin/env bash

kubectx docker-desktop
flux uninstall -n flux-system -s --timeout 10s
kubectl delete -k busybox/overlays/dev
kubectx do-sfo3-gitopslab
kubectx
flux uninstall -n flux-system -s --timeout 10s
kubectl delete -k busybox/overlays/prod
kubectx

\rm -rf clusters
git rm -r clusters
git commit -m "remove clusters"
git push

