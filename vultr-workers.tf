resource "vultr_server" "workers" {
  count			 = terraform.workspace == "default" ? var.worker_count : 2
  plan_id		 = data.vultr_plan.worker_plan.id
  region_id		 = data.vultr_region.cluster_region.id
  os_id			 = data.vultr_os.cluster_os.id
  hostname		 = terraform.workspace == "default" ? "${var.cluster_name}-worker-${count.index}" : "${var.cluster_name}-${terraform.workspace}-worker-${count.index}"
  label			 = terraform.workspace == "default" ? "${var.cluster_name}-worker-${count.index}" : "${var.cluster_name}-${terraform.workspace}-worker-${count.index}"
  network_ids		 = [vultr_network.cluster_network.id]
  ssh_key_ids            = [vultr_ssh_key.provisioner.id]

  lifecycle {
    create_before_destroy = true
  }

  connection {
    type           = "ssh"
    host           = self.main_ip
    user           = "root"
    private_key    = file("~/.ssh/id_rsa")
  }

  provisioner "file" {
    source      = "${path.module}/scripts/common/remote/"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [ "set -euxo", "chmod +x /tmp/common-provisioner.sh", "/tmp/common-provisioner.sh ${var.docker_release} ${var.containerd_release}" ]
  }
}

resource "null_resource" "worker_join" {
  depends_on = [null_resource.cluster_init, vultr_server.workers]

  count = length(vultr_server.workers.*.id)

  triggers = {
    worker_id = vultr_server.workers[count.index].id  
  }

  connection {
    type     = "ssh"
    host     = vultr_server.controllers[0].main_ip
    user     = "root"
    password = vultr_server.controllers[0].default_password
  }

  provisioner "remote-exec" {
    inline = [
      "if test -d ~/join; then echo \"creating token\"; else mkdir ~/join; fi",
      "kubeadm token create --print-join-command > ~/join/worker-${count.index}-join",
    ]
  }

  provisioner "local-exec" {
    command = "scp root@${vultr_server.controllers[0].main_ip}:~/join/worker-${count.index}-join ${path.module}/scripts/worker/local/worker-${count.index}-join"
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = vultr_server.workers[count.index].main_ip
      user     = "root"
      password = vultr_server.workers[count.index].default_password
    }

    inline = [ file("${path.module}/scripts/worker/local/worker-${count.index}-join") ]
  }

  provisioner "remote-exec" {
    inline = [
      "kubeadm token delete $(cat join/worker-${count.index}-join | awk '{print $5}')",
      "rm -f ~/join/worker-${count.index}-join",      
    ]
  }

  provisioner "local-exec" {
    command = "rm -f ${path.module}/scripts/worker/local/worker-${count.index}-join"
  }
}

