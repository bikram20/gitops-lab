resource "digitalocean_kubernetes_cluster" "gitopslab" {
  name   = "gitopslab"
  region = "sfo3"
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.20.2-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-4gb"
    auto_scale = true
    min_nodes  = 3
    max_nodes  = 5
  }
}

#data "digitalocean_kubernetes_cluster" "logging" {
#  name = "logging"
#}
#
#provider "kubernetes" {
#  host             = data.digitalocean_kubernetes_cluster.example.endpoint
#  token            = data.digitalocean_kubernetes_cluster.example.kube_config[0].token
#  cluster_ca_certificate = base64decode(
#    data.digitalocean_kubernetes_cluster.example.kube_config[0].cluster_ca_certificate
#  )
#}
