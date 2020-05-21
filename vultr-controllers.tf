resource "vultr_server" "controllers" {
  count			 = var.controller_count 
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

  provisioner "file" {
    source      = "${path.module}/scripts/common/remote/"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [ "set -euxo", "chmod +x /tmp/common-provisioner.sh", "/tmp/common-provisioner.sh ${var.docker_release} ${var.containerd_release} ${var.k8_release}" ]
  }
}

resource "null_resource" "cluster_init" {
  count = var.controller_count > 1 ? 0 : 1

  depends_on = [vultr_server.controllers[0]]

  connection {
    type     = "ssh"
    host     = vultr_server.controllers[0].main_ip
    user     = "root"
    password = vultr_server.controllers[0].default_password
  }

  provisioner "remote-exec" {
    inline = [ 
      "set -euxo", 
      "kubeadm init --apiserver-advertise-address=0.0.0.0 --pod-network-cidr=${var.pod_network_cidr}", 
      "mkdir -p $HOME/.kube", 
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config",
      "mkdir ~/vultr",
    ]
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${vultr_server.controllers[0].main_ip}:~/.kube/config admin-${terraform.workspace}.config"
  }

  provisioner "file" {
    content     = templatefile("${path.module}/templates/vultr/ccm-api-key.yml.tpl", { CLUSTER_API_KEY = var.cluster_api_key, CLUSTER_REGION = data.vultr_region.cluster_region.id }) 
    destination = "~/vultr/ccm-api-key.yml"
  }

  provisioner "file" {
    content     = templatefile("${path.module}/templates/vultr/csi-api-key.yml.tpl", { CLUSTER_API_KEY = var.cluster_api_key }) 
    destination = "~/vultr/csi-api-key.yml"
  }

  provisioner "file" {
    content     = data.http.vultr_ccm_file.body
    destination = "~/vultr/vultr-ccm.yml" 
  }

  provisioner "file" {
    content     = data.http.vultr_csi_file.body
    destination = "~/vultr/vultr-csi.yml" 
  }

  provisioner "remote-exec" {
    inline = [
      "set -euxo",
      "kubectl apply -f ${var.cluster_cni}",
      "kubectl apply -f ~/vultr/ccm-api-key.yml",
      "kubectl apply -f ~/vultr/csi-api-key.yml",
      "kubectl apply -f ~/vultr/vultr-ccm.yml",
      "kubectl apply -f ~/vultr/vultr-csi.yml",
    ]
  }
}

resource "null_resource" "cluster_init_ha" {
  count = var.controller_count > 1 ? 1 : 0

  depends_on = [vultr_server.controllers[0], vultr_load_balancer.external_lb[0]]

  connection {
    type     = "ssh"
    host     = vultr_server.controllers[0].main_ip
    user     = "root"
    password = vultr_server.controllers[0].default_password
  }

  provisioner "remote-exec" {
    inline = [ 
      "set -euxo", 
      "stdbuf -o 0 kubeadm init --control-plane-endpoint=${var.kube_api_dns_subdomain}.${var.cluster_domain}:${var.external_lb_frontend_port} --upload-certs --pod-network-cidr=${var.pod_network_cidr} 2>&1 | tee /tmp/cluster_init.log", 
      "mkdir -p $HOME/.kube", 
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config",
      "cat /tmp/cluster_init.log | tr -d '\\n' | tr -d '\\\\' | grep -Po \"kubeadm join ${var.kube_api_dns_subdomain}.${var.cluster_domain}:${var.external_lb_frontend_port} --token [a-zA-Z0-9]{6}.[a-zA-Z0-9]{16}     --discovery-token-ca-cert-hash sha256:[a-zA-Z0-9]{64}     --control-plane --certificate-key [a-zA-Z0-9]{64}\" > /tmp/controller-join-command",
      "mkdir ~/vultr",
    ]
  }  

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${vultr_server.controllers[0].main_ip}:~/.kube/config admin-${terraform.workspace}.config"
  }

  provisioner "file" {
    content     = templatefile("${path.module}/templates/vultr/ccm-api-key.yml.tpl", { CLUSTER_API_KEY = var.cluster_api_key, CLUSTER_REGION = data.vultr_region.cluster_region.id })
    destination = "~/vultr/ccm-api-key.yml"
  }

  provisioner "file" {
    content     = templatefile("${path.module}/templates/vultr/csi-api-key.yml.tpl", { CLUSTER_API_KEY = var.cluster_api_key })
    destination = "~/vultr/csi-api-key.yml"
  }

  provisioner "file" {
    content     = data.http.vultr_ccm_file.body
    destination = "~/vultr/vultr-ccm.yml"
  }

  provisioner "file" {
    content     = data.http.vultr_csi_file.body
    destination = "~/vultr/vultr-csi.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f ${var.cluster_cni}",
      "kubectl apply -f ~/vultr/ccm-api-key.yml",
      "kubectl apply -f ~/vultr/csi-api-key.yml",
      "kubectl apply -f ~/vultr/vultr-ccm.yml",
      "kubectl apply -f ~/vultr/vultr-csi.yml",
    ]
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${vultr_server.controllers[0].main_ip}:/tmp/controller-join-command ${path.module}/scripts/controller/remote/controller-join"
  }
}

resource "null_resource" "ha_controller_join" {
  depends_on = [null_resource.cluster_init_ha, vultr_server.controllers]

  count = var.controller_count > 1 ? length(vultr_server.controllers.*.id) - 1 : 0

  provisioner "remote-exec" {

    connection {
      type     = "ssh"
      host     = vultr_server.controllers[count.index + 1].main_ip
      user     = "root"
      password = vultr_server.controllers[count.index + 1].default_password
    }

    inline = [ file("${path.module}/scripts/controller/remote/controller-join") ]
  }

  connection {
    type     = "ssh"
    host     = vultr_server.controllers[0].main_ip
    user     = "root"
    password = vultr_server.controllers[0].default_password
  }

  provisioner "remote-exec" {
    inline = [
      "rm -f /tmp/cluster_init.log",
      "rm -f /tmp/controller-join-command"
    ]
  }

  provisioner "local-exec" {
    command = "rm -f ${path.module}/scripts/controller/remote/controller-join"
  }
}


