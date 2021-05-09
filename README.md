# GitOps hands-on for Developers on DigitalOcean Kubernetes (DOKS)

## Objectives
- Maintain a single source of truth (base manifests) in GitHub for your dev, staging, and prod clusters.
- Use *kustomize* to modify the manifests targeted to specific clusters.
- Use *flux 2* for reconciling GitHub source-of-truth with the cluster.

## Create clusters in DOKS and local laptop 

cd terraform-doks/


terraform init</br>
terraform plan</br>
terraform apply


Note: You need to pass the DO access (secret password) token to terraform. One option is:</br>
export DIGITALOCEAN_ACCESS_TOKEN='<your secret token>'


terraform output will show the cluster id. Build the kubeconfig.</br>
doctl kubernetes cluster kubeconfig save <cluster_id>


Additionally, install Docker desktop, or kind, or any other distribution of your choice for your local laptop.

```
bgupta@C02CC1EGMD6M gitops-lab % kubectx
do-sfo3-gitopslab
docker-desktop
bgupta@C02CC1EGMD6M gitops-lab % 
```


## Set up flux for GitOps

Install flux on your laptop. You can find appropriate command for non-mac clients in https://fluxcd.io/docs/get-started/. </br>
brew install flux 

Note: You need to export GITHUB_TOKEN and GITHUB_USER for Flux. This is what Flux will use to connect to your GitHub. 

```
bgupta@C02CC1EGMD6M gitops-lab % flux bootstrap github --owner=$GITHUB_USER --repository=gitops-lab --branch=master \
> --path=./clusters/do-prod
► connecting to github.com
► cloning branch "master" from Git repository "https://github.com/bikram20/gitops-lab.git"
✔ cloned repository
► generating component manifests
✔ generated component manifests
✔ committed sync manifests to "master" ("6597a74b5836c13229121a9974d5b1091f76fc8d")
► pushing component manifests to "https://github.com/bikram20/gitops-lab.git"
► installing components in "flux-system" namespace
```

Likewise, set up flux on your local cluster.

```
bgupta@C02CC1EGMD6M do-prod % kubectx docker-desktop
Switched to context "docker-desktop".
bgupta@C02CC1EGMD6M do-prod % kubectx
do-sfo3-gitopslab
docker-desktop
bgupta@C02CC1EGMD6M do-prod % 
bgupta@C02CC1EGMD6M do-prod % flux bootstrap github --owner=$GITHUB_USER \
--repository=gitops-lab --branch=master --path=./clusters/local-dev
...
...
```

Now you can clone or refresh your git repo, which was created/updated by Flux. Changes to that repo are picked up by Flux.

The key concepts to know are the CRDs and controllers created by Flux. Our interest is in gitrepository and kustomization. Gitrepository tells flux the location of manifests. Kustomization tells flux HOW to install those. You can have as many of these from as many locations you want. 

```
bgupta@C02CC1EGMD6M clusters % kubectl get crd
NAME                                         CREATED AT
alerts.notification.toolkit.fluxcd.io        2021-05-09T18:14:01Z
buckets.source.toolkit.fluxcd.io             2021-05-09T18:14:01Z
gitrepositories.source.toolkit.fluxcd.io     2021-05-09T18:14:01Z
helmcharts.source.toolkit.fluxcd.io          2021-05-09T18:14:01Z
helmreleases.helm.toolkit.fluxcd.io          2021-05-09T18:14:01Z
helmrepositories.source.toolkit.fluxcd.io    2021-05-09T18:14:01Z
kustomizations.kustomize.toolkit.fluxcd.io   2021-05-09T18:14:01Z
providers.notification.toolkit.fluxcd.io     2021-05-09T18:14:01Z
receivers.notification.toolkit.fluxcd.io     2021-05-09T18:14:01Z
bgupta@C02CC1EGMD6M clusters % 
bgupta@C02CC1EGMD6M clusters % kubectl get gitrepository -A
NAMESPACE     NAME          URL                                        READY   flux-system   flux-system   ssh://git@github.com/bikram20/gitops-lab   True    bgupta@C02CC1EGMD6M clusters % kubectl get kustomizations -A
NAMESPACE     NAME          READY   flux-system   flux-system   True    Applied revision: master/b697a14630686d36e487fba1e5a80e926ebe7c49   7m18s
bgupta@C02CC1EGMD6M clusters % 
```

And Flux will reconcile the cluster to the source-of-truth (Git). Even if we make changes manually to the manifests installed by Flux, those will be restored. You can easily create various alerting options as well.

FROM HERE ON, WE WILL MAKE ALL CHANGES TO THE CLUSTERS THROUGH GIT REPO.

## Create a busybox pod
First, tell Flux on how (kustomization) to install. We are going to use the SAME git repo (flux-system <-> gitsops-lab)

```
bgupta@C02CC1EGMD6M gitops-lab % flux create kustomization busybox \
  --source=flux-system \
  --path=“./busybox" \
  --prune=true \
  --validation=client \
  --interval=5m \
  --export > ./clusters/local-dev/kustomization-busybox.yaml
bgupta@C02CC1EGMD6M gitops-lab % 
```

Commit and push the code to GitHub. Now busybox pod should be running in busybox namespace.

```
bgupta@C02CC1EGMD6M gitops-lab % flux get kustomization -A
NAMESPACE       NAME            READY   MESSAGE                                                                 REVISION                                        SUSPENDED 
flux-system     busybox         True    Applied revision: master/8609c5d8fca1f22f86f621197f13085445a0d302       master/8609c5d8fca1f22f86f621197f13085445a0d302 False    
flux-system     flux-system     True    Applied revision: master/8609c5d8fca1f22f86f621197f13085445a0d302       master/8609c5d8fca1f22f86f621197f13085445a0d302 False    
bgupta@C02CC1EGMD6M gitops-lab % kgns
NAME              STATUS   AGE
busybox           Active   8s
default           Active   20d
flux-system       Active   27m
kube-node-lease   Active   20d
kube-public       Active   20d
kube-system       Active   20d
bgupta@C02CC1EGMD6M gitops-lab %
```




