resource "vultr_network" "cluster_network" {
    description = "${var.cluster_name} private network."
    region_id = data.vultr_region.cluster_region.id
}

