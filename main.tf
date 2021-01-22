locals {
  cluster_name = "${var.cluster_name}-${random_id.cluster.hex}"
}

data "vultr_os" "cluster_os" {
  filter {
    name   = "name"
    values = [var.cluster_os]
  }
}

resource "random_id" "cluster" {
  byte_length = 8
}

resource "vultr_firewall_group" "condor_firewall" {
  count       = var.firewall_group_id == "" ? 1 : 0
  description = "Firewall for Condor cluster: ${local.cluster_name}"
}

resource "vultr_private_network" "condor_network" {
  description    = "Private Network for Condor cluster: ${local.cluster_name}"
  region         = var.cluster_region
  v4_subnet      = var.condor_network_subnet
  v4_subnet_mask = var.condor_network_subnet_mask
}

resource "vultr_instance" "controllers" {
  count               = var.controller_count
  plan                = var.controller_machine_type
  region              = var.cluster_region
  os_id               = data.vultr_os.cluster_os.id
  label               = "${local.cluster_name}-controller-${count.index}"
  hostname            = "${local.cluster_name}-controller-${count.index}"
  tag                 = var.tag
  enable_ipv6         = var.enable_ipv6
  backups             = var.enable_backups
  ddos_protection     = var.enable_ddos_protection
  activation_email    = var.enable_activation_email
  firewall_group_id   = var.firewall_group_id == "" ? vultr_firewall_group.condor_firewall[0].id : var.firewall_group_id
  private_network_ids = [vultr_private_network.condor_network.id]

  connection {
    type     = "ssh"
    user     = "root"
    password = self.default_password
    host     = self.main_ip
  }

  provisioner "file" {
    content     = templatefile("${path.module}/scripts/condor-provision.sh", { CONTAINERD_RELEASE = var.containerd_release, K8_VERSION = var.k8_version })
    destination = "/tmp/condor-provision.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/condor-provision.sh",
      "/tmp/condor-provision.sh",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/files/containerd/config.toml"
    destination = "/etc/containerd/config.toml"
  }

  provisioner "remote-exec" {
    inline = ["systemctl restart containerd"]
  }
}

resource "vultr_instance" "workers" {
  count               = var.worker_count
  plan                = var.worker_machine_type
  region              = var.cluster_region
  os_id               = data.vultr_os.cluster_os.id
  label               = "${local.cluster_name}-worker-${count.index}"
  hostname            = "${local.cluster_name}-worker-${count.index}"
  tag                 = var.tag
  enable_ipv6         = var.enable_ipv6
  backups             = var.enable_backups
  ddos_protection     = var.enable_ddos_protection
  activation_email    = var.enable_activation_email
  firewall_group_id   = var.firewall_group_id == "" ? vultr_firewall_group.condor_firewall[0].id : var.firewall_group_id
  private_network_ids = [vultr_private_network.condor_network.id]

  connection {
    type     = "ssh"
    user     = "root"
    password = self.default_password
    host     = self.main_ip
  }

  provisioner "file" {
    content     = templatefile("${path.module}/scripts/condor-provision.sh", { CONTAINERD_RELEASE = var.containerd_release, K8_VERSION = var.k8_version })
    destination = "/tmp/condor-provision.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/condor-provision.sh",
      "/tmp/condor-provision.sh",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/files/containerd"
    destination = "/etc/containerd"
  }

  provisioner "remote-exec" {
    inline = ["systemctl restart containerd"]
  }
}

resource "null_resource" "cluster_init" {
  depends_on = [vultr_instance.controllers]

  connection {
    type     = "ssh"
    user     = "root"
    host     = vultr_instance.controllers[0].main_ip
    password = vultr_instance.controllers[0].default_password
  }

  provisioner "file" {
    content     = templatefile("${path.module}/files/kubeadm/kubeadm-init.conf", { POD_NETWORK_CIDR = var.pod_network_cidr, CONTROL_PLANE_INTERNAL_IP = vultr_instance.controllers[0].internal_ip, CONTROL_PLANE_PUBLIC_IP = vultr_instance.controllers[0].main_ip })
    destination = "/tmp/kubeadm-init.conf"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/condor-init.sh"
    destination = "/tmp/condor-init.sh"
  }

  provisioner "file" {
    content     = templatefile("${path.module}/files/cni/flannel/kube-flannel.yml", { POD_NETWORK_CIDR = var.pod_network_cidr })
    destination = "/tmp/kube-flannel.yml"
  }

  provisioner "file" {
    content     = templatefile("${path.module}/files/vultr/vultr-api-key.yml", { CLUSTER_VULTR_API_KEY = var.cluster_vultr_api_key, CLUSTER_REGION = var.cluster_region })
    destination = "/tmp/vultr-api-key.yml"
  }

  provisioner "file" {
    content     = templatefile("${path.module}/files/vultr/vultr-ccm.yml", { VULTR_CCM_VERSION = var.vultr_ccm_version })
    destination = "/tmp/vultr-ccm.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/condor-init.sh",
      "/tmp/condor-init.sh",
    ]
  }
}
