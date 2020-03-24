resource "vultr_network" "cluster_network" {
    description = terraform.workspace == "default" ? "${var.cluster_name} private network." : "${var.cluster_name} ${terraform.workspace} private network."
    region_id = data.vultr_region.cluster_region.id
}

