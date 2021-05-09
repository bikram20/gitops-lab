# GitOps hands-on for Developers on DigitalOcean Kubernetes (DOKS)

## Objectives
- Maintain a single source of truth (base manifests) in GitHub for your dev, staging, and prod clusters.
- Use *kustomize* to modify the manifests targeted to specific clusters.
- Use *flux 2* for reconciling GitHub source-of-truth with the cluster.

## Create a prod cluster in DOKS 

terraform init
terraform plan
terraform apply


Note: You need to pass the DO access (secret password) token to terraform. One option is:

export DIGITALOCEAN_ACCESS_TOKEN='<your secret token>'


terraform output will show the cluster id. Build the kubeconfig.

doctl kubernetes cluster kubeconfig save <cluster_id>

