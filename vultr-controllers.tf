resource "vultr_server" "controllers" {
  count			 = var.controller_count # HA Not currently supported
  plan_id		 = data.vultr_plan.controller_plan.id
  region_id		 = data.vultr_region.cluster_region.id
  os_id			 = data.vultr_os.cluster_os.id
  hostname		 = terraform.workspace == "default" ? "${var.cluster_name}-controller-${count.index}" : "${var.cluster_name}-${terraform.workspace}-controller-${count.index}"
  label			 = terraform.workspace == "default" ? "${var.cluster_name}-controller-${count.index}" : "${var.cluster_name}-${terraform.workspace}-controller-${count.index}"
  network_ids		 = [vultr_network.cluster_network.id]
  ssh_key_ids            = [vultr_ssh_key.provisioner.id]

  connection {
    type           = "ssh"
    host           = self.main_ip
    user           = "root"
    private_key    = file("~/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/common/remote/common-provisioner.sh"
  }
}

resource "null_resource" "cluster_init" {
  depends_on = [vultr_server.controllers]

  connection {
    type     = "ssh"
    host     = vultr_server.controllers[0].main_ip
    user     = "root"
    password = vultr_server.controllers[0].default_password
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/controller/remote/cluster-init.sh"
  }
}



