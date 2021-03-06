locals {
  cluster_name        = "${var.cluster_name}-${random_id.cluster.hex}"
  cluster_public_keys = concat([vultr_ssh_key.cluster_provisioner.id], vultr_ssh_key.extra_public_keys.*.id)
  pre_provisioned     = var.custom_snapshot_description != "" ? true : false
}

resource "vultr_ssh_key" "cluster_provisioner" {
  name    = "Provisioner public key for Condor cluster: ${local.cluster_name}"
  ssh_key = var.provisioner_public_key
}

resource "vultr_ssh_key" "extra_public_keys" {
  count   = length(var.extra_public_keys)
  name    = "Public Key for Condor Cluster: ${local.cluster_name}"
  ssh_key = var.extra_public_keys[count.index]
}

data "vultr_os" "cluster_os" {
  filter {
    name   = "name"
    values = [var.cluster_os]
  }
}

data "vultr_snapshot" "cluster_snapshot" {
  count = var.custom_snapshot_description != "" ? 1 : 0
  filter {
    name   = "description"
    values = [var.custom_snapshot_description]
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
  os_id               = local.pre_provisioned ? null : data.vultr_os.cluster_os.id
  snapshot_id         = local.pre_provisioned ? data.vultr_snapshot.cluster_snapshot[0].id : ""
  label               = "${local.cluster_name}-controller-${count.index}"
  hostname            = "${local.cluster_name}-controller-${count.index}"
  tag                 = var.tag
  enable_ipv6         = var.enable_ipv6
  backups             = var.enable_backups
  ddos_protection     = var.enable_ddos_protection
  activation_email    = var.enable_activation_email
  firewall_group_id   = var.firewall_group_id == "" ? vultr_firewall_group.condor_firewall[0].id : var.firewall_group_id
  private_network_ids = [vultr_private_network.condor_network.id]
  ssh_key_ids         = local.cluster_public_keys

  connection {
    type     = "ssh"
    user     = "root"
    host     = self.main_ip
  }

  provisioner "file" {
    content     = templatefile("${path.module}/scripts/condor-provision.sh", { CONTAINERD_RELEASE = var.containerd_release, K8_VERSION = var.k8_version, PRE_PROVISIONED = local.pre_provisioned })
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
  os_id               = local.pre_provisioned ? null : data.vultr_os.cluster_os.id
  snapshot_id         = local.pre_provisioned ? data.vultr_snapshot.cluster_snapshot[0].id : ""
  label               = "${local.cluster_name}-worker-${count.index}"
  hostname            = "${local.cluster_name}-worker-${count.index}"
  tag                 = var.tag
  enable_ipv6         = var.enable_ipv6
  backups             = var.enable_backups
  ddos_protection     = var.enable_ddos_protection
  activation_email    = var.enable_activation_email
  firewall_group_id   = var.firewall_group_id == "" ? vultr_firewall_group.condor_firewall[0].id : var.firewall_group_id
  private_network_ids = [vultr_private_network.condor_network.id]
  ssh_key_ids         = local.cluster_public_keys

  connection {
    type     = "ssh"
    user     = "root"
    host     = self.main_ip
  }

  provisioner "file" {
    content     = templatefile("${path.module}/scripts/condor-provision.sh", { CONTAINERD_RELEASE = var.containerd_release, K8_VERSION = var.k8_version, PRE_PROVISIONED = local.pre_provisioned })
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

resource "null_resource" "cluster_init" {
  depends_on = [vultr_instance.controllers]

  connection {
    type     = "ssh"
    user     = "root"
    host     = vultr_instance.controllers[0].main_ip
  }

  provisioner "file" {
    content     = templatefile("${path.module}/files/kubeadm/kubeadm-init.conf", { POD_NETWORK_CIDR = var.pod_network_cidr, CONTROL_PLANE_INTERNAL_IP = vultr_instance.controllers[0].internal_ip, CONTROL_PLANE_PUBLIC_IP = vultr_instance.controllers[0].main_ip })
    destination = "/tmp/kubeadm-init.conf"
  }

  provisioner "file" {
    content     = file("${path.module}/scripts/condor-init.sh")
    destination = "/tmp/condor-init.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/condor-init.sh",
      "/tmp/condor-init.sh",
    ]
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${vultr_instance.controllers[0].main_ip}:/root/.kube/config admin.conf && sed -i.bak 's/${vultr_instance.controllers[0].internal_ip}/${vultr_instance.controllers[0].main_ip}/g' admin.conf"
  }
}

resource "null_resource" "calico_cni" {
  depends_on = [ null_resource.cluster_init ]

  triggers = {
    calico_version = var.kube_calico_version
  }

  connection {
    type     = "ssh"
    user     = "root"
    host     = vultr_instance.controllers[0].main_ip
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f https://docs.projectcalico.org/v${var.kube_calico_version}/manifests/calico.yaml"
    ]
  }
}

resource "null_resource" "vultr_ccm_api_key" {
  depends_on = [ null_resource.cluster_init ]

  triggers = {
    ccm_api_key = var.cluster_vultr_api_key
  }

  connection {
    type     = "ssh"
    user     = "root"
    host     = vultr_instance.controllers[0].main_ip
  }

  provisioner "remote-exec" {
    inline = [
      <<-EOT
        cat <<-EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: vultr-ccm
  namespace: kube-system
stringData:
  api-key: "${var.cluster_vultr_api_key}"
  region: "${var.cluster_region}"
---
apiVersion: v1
kind: Secret
metadata:
  name: vultr-csi
  namespace: kube-system
stringData:
  api-key: "${var.cluster_vultr_api_key}"
      EOT
    ]
  }
}

resource "null_resource" "vultr_ccm" {
  depends_on = [ null_resource.cluster_init ]

  triggers = {
    ccm_version = var.vultr_ccm_version
  }

  connection {
    type     = "ssh"
    user     = "root"
    host     = vultr_instance.controllers[0].main_ip
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f https://raw.githubusercontent.com/vultr/vultr-cloud-controller-manager/master/docs/releases/${var.vultr_ccm_version}.yml"
    ]
  }
}

resource "null_resource" "vultr_csi" {
  depends_on = [ null_resource.cluster_init ]

  triggers = {
    csi_version = var.vultr_csi_version
  }

  connection {
    type     = "ssh"
    user     = "root"
    host     = vultr_instance.controllers[0].main_ip
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f https://raw.githubusercontent.com/vultr/vultr-csi/master/docs/releases/${var.vultr_csi_version}.yml"
    ]
  }
}

resource "null_resource" "worker_join" {
  depends_on = [null_resource.cluster_init, vultr_instance.workers]

  triggers = {
    worker_id = vultr_instance.workers[count.index].id
  }

  count = var.worker_count

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = vultr_instance.controllers[0].main_ip
      user     = "root"
    }

    inline = [
      "kubeadm token create --print-join-command > /tmp/worker-${count.index}-join"
    ]
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -3 root@${vultr_instance.controllers[0].main_ip}:/tmp/worker-${count.index}-join root@${vultr_instance.workers[count.index].main_ip}:/tmp/worker-${count.index}-join"
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = vultr_instance.workers[count.index].main_ip
      user     = "root"
    }

    inline = [
      "bash -euxo pipefail -c \"$(cat /tmp/worker-${count.index}-join)\"",
      "rm -f /tmp/worker-${count.index}-join"
    ]
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = vultr_instance.controllers[0].main_ip
      user     = "root"
    }

    inline = [
      "kubeadm token delete $(cat /tmp/worker-${count.index}-join | awk '{print $5}')",
      "rm -f /tmp/worker-${count.index}-join"
    ]
  }
}
