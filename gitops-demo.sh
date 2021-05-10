#!/usr/bin/env bash
# shellcheck source=demo-magic.sh
source demo-magic.sh
clear

GITHUB_USER=bikram20
GITHUB_TOKEN=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

if false; then
# ... Code I want to skip here ...
echo
fi

pe "kubectx"
pe "flux -v"

pe "kubectx do-sfo3-gitopslab"
pe "kubectl get ns; kubectl get po -A"
pe "flux bootstrap github --owner=$GITHUB_USER --repository=gitops-lab --branch=master \
--path=./clusters/do-prod"
pe "kubectl get ns; kubectl get po -A"

pe "kubectx docker-desktop"
pe "kubectl get ns; kubectl get po -A"
pe "flux bootstrap github --owner=$GITHUB_USER --repository=gitops-lab --branch=master \
--path=./clusters/local-dev"
pe "kubectl get ns; kubectl get po -A"

pe "git pull"

pe "kubectx do-sfo3-gitopslab"
pe "kubectl get crd"
pe "kubectl get gitrepositories -A"
pe "kubectl get kustomizations -A"
pe "flux create kustomization busybox \
--source=flux-system \
--path=\"./busybox/overlays/prod\" \
--prune=true \
--validation=client \
--interval=1m \
--export > ./clusters/do-prod/kustomization-busybox.yaml"

pe "git add ./clusters/do-prod/kustomization-busybox.yaml"
pe "git commit -m \"add busybox to prod\""
pe "git push"
pe "kubectl get ns; kubectl get po -n busybox"

pe "kubectx docker-desktop"
pe "flux create kustomization busybox \
--source=flux-system \
--path=\"./busybox/overlays/dev\" \
--prune=true \
--validation=client \
--interval=1m \
--export > ./clusters/local-dev/kustomization-busybox.yaml"
pe "git add ./clusters/local-dev/kustomization-busybox.yaml"
pe "git commit -m \"add busybox to local dev\""
pe "git push"
pe "kubectl get ns; kubectl get po -n busybox"

pe "kubectx do-sfo3-gitopslab"
pe "kubectl get ns"
pe "kubectl get po -n busybox"

pe "kubectx docker-desktop"
pe "kubectl get ns"
pe "kubectl get po -n busybox"
