variable "env" {}
variable "project_id" {}
variable "region" {
    default = "us-west2"
}
variable "network" {}
variable "subnetwork" {}
variable "ip_range_pods_name" {}
variable "ip_range_services_name" {}
variable "cluster_name" {}
variable "cluster_machine_type" {}
variable "cluster_node_locations" {}
variable "cluster_disk_size_gb" {}
variable "cluster_disk_type" {}
variable "enable_gke_cluster_count" {
    default = false
}
