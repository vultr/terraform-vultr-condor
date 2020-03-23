resource "vultr_server" "workers" {
  count			 = var.worker_count 
  plan_id		 = data.vultr_plan.worker_plan.id
  region_id		 = data.vultr_region.cluster_region.id
  os_id			 = data.vultr_os.cluster_os.id
  hostname		 = "${var.cluster_name}-worker-${count.index}"
  label			 = "${var.cluster_name}-worker-${count.index}"
  network_ids		 = [vultr_network.cluster_network.id]
  ssh_key_ids            = [vultr_ssh_key.provisioner.id]

  connection {
    type           = "ssh"
    host           = self.main_ip
    user           = "root"
    private_key    = file("~/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "set -euxo",
      "yum -y install systemd-networkd systemd-resolved",
      "systemctl disable network NetworkManager",
      "systemctl enable systemd-networkd systemd-resolved",
      "rm -f /etc/resolv.conf",
      "ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf",
      "mkdir /etc/systemd/network/",  
    ]
  }

  provisioner "file" {
    content     = templatefile("${path.module}/files/network/00-eth1.network.tpl", { PRIVATE_IP=self.internal_ip })
    destination = "/etc/systemd/network/00-eth1.network"
  }

  provisioner "file" {
    source      = "${path.module}/files/network/00-eth0.network"
    destination = "/etc/systemd/network/00-eth0.network"
  }

  provisioner "remote-exec" {
    inline = [
      "set -euxo",
      "systemctl restart systemd-networkd systemd-resolved",
    ]  
  }

  provisioner "remote-exec" {
    inline = [ 
      "set -euxo",
      "yum -y update",
#      "setenforce 0",
#      "sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config",
      "yum install -y yum-utils device-mapper-persistent-data",
      "yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
      "yum -y update",
      "yum -y install containerd.io-1.2.10 docker-ce-${var.docker_release} docker-ce-${var.docker_release}",
      "mkdir /etc/docker",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/files/docker/daemon.json"
    destination = "/etc/docker/daemon.json" 
  }

  provisioner "file" {
    source      = "${path.module}/files/kubernetes/kubernetes.repo"
    destination = "/etc/yum.repos.d/kubernetes.repo"
  }

  provisioner "file" {
    source      = "${path.module}/files/kubernetes/kubelet-extra-args"
    destination = "/etc/sysconfig/kubelet"
  }

  provisioner "file" {
    source      = "${path.module}/files/kubernetes/k8s.conf"
    destination = "/etc/sysctl.d/k8s.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "set -euxo",
      "mkdir -p /etc/systemd/system/docker.service.d",
      "systemctl daemon-reload",
      "systemctl restart docker",
      "yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes",
      "systemctl disable firewalld",
      "systemctl stop firewalld",
      "sysctl --system",
      "systemctl enable kubelet",
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "worker_provisioner" {
  depends_on = [null_resource.controller_provisioner]

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
    inline = [
      "${file("${path.module}/files/remote/join-command")}"
    ]
  }
}

