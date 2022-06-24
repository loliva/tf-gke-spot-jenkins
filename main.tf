data "google_client_config" "default" {}

data "google_container_engine_versions" "west2" {
  project        = var.project_id
  provider       = google-beta
  location       = var.region
  version_prefix = "1.23."
}

//cluster regional
module "gke" {
  source                 = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"
  project_id             = var.project_id
  name                   = var.cluster_name
  regional               = true
  region                 = var.region
  network                = var.network
  subnetwork             = var.subnetwork
  ip_range_pods          = var.ip_range_pods_name
  ip_range_services      = var.ip_range_services_name
  horizontal_pod_autoscaling = true
  http_load_balancing    = true
  initial_node_count     = 1
  create_service_account = true
  remove_default_node_pool = true
  logging_service        = "none"
  kubernetes_version     = data.google_container_engine_versions.west2.latest_node_version
  cluster_resource_labels = {
    cluster = var.cluster_name
  }
    node_pools = [
      {
        name                      = "${var.cluster_name}-node-pool"
        machine_type              = var.cluster_machine_type
        node_locations            = var.cluster_node_locations
        initial_node_count        = 1
        min_count                 = 1 // minimo un nodo por zona
        max_count                 = 1 // maximo un nodo por zona
        disk_size_gb              = var.cluster_disk_size_gb
        disk_type                 = var.cluster_disk_type
        image_type                = "COS_CONTAINERD"
        auto_repair               = true
        auto_upgrade              = true
        autoscaling               = true
        spot                      = true
      },
    ]
}
