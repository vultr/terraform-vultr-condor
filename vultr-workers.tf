resource "vultr_server" "workers" {
  count			 = terraform.workspace == "default" ? var.worker_count : 2
  plan_id		 = data.vultr_plan.worker_plan.id
  region_id		 = data.vultr_region.cluster_region.id
  os_id			 = data.vultr_os.cluster_os.id
  hostname		 = terraform.workspace == "default" ? "${var.cluster_name}-worker-${count.index}" : "${var.cluster_name}-${terraform.workspace}-worker-${count.index}"
  label			 = terraform.workspace == "default" ? "${var.cluster_name}-worker-${count.index}" : "${var.cluster_name}-${terraform.workspace}-worker-${count.index}"
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

resource "null_resource" "worker_join" {
  depends_on = [null_resource.cluster_cluster_init]

  count = length(vultr_server.workers.*.id)

  triggers = {
    worker_id = vultr_server.workers[count.index].id  
  }

  connection {
    type     = "ssh"
    host     = vultr_server.workers[count.index].main_ip
    user     = "root"
    password = vultr_server.workers[count.index].default_password
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/worker/remote/worker-join.sh"
  }
}

