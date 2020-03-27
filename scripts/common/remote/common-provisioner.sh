#!/bin/bash

set -euxo posix

if [ $# -ne 3 ]; then
	echo "common-provisioner.sh requires 3 parameters"
	exit 1
fi

yum -y update
yum -y install epel-release
yum -y install jq curl

INSTANCE_METADATA=$(curl --silent http://169.254.169.254/v1.json)
PRIVATE_IP=$(echo $INSTANCE_METADATA | jq -r .interfaces[1].ipv4.address)
DOCKER_RELEASE="$1"
CONTAINERD_RELEASE="$2"
K8_RELEASE=$(echo $3 | sed 's/v//')

pre_dependencies(){
	cat <<-EOF > /etc/sysctl.d/k8s.conf
		net.bridge.bridge-nf-call-ip6tables = 1
		net.bridge.bridge-nf-call-iptables = 1
		EOF

	sysctl --system
}

network_config(){
	yum -y install systemd-networkd systemd-resolved
	systemctl disable network NetworkManager
	rm -f /etc/resolv.conf
	ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
	mkdir /etc/systemd/network

	cat <<-EOF > /etc/systemd/network/eth0.network
		[Match]
		Name=eth0

		[Network]
		DHCP=yes
		EOF

	cat <<-EOF > /etc/systemd/network/eth1.network
		[Match]
		Name=eth1

		[Network]
		Address=$PRIVATE_IP
		EOF

	systemctl enable systemd-networkd systemd-resolved
	systemctl restart systemd-networkd systemd-resolved
}

install_k8(){
	cat <<-EOF > /etc/yum.repos.d/kubernetes.repo
		[kubernetes]
		name=Kubernetes
		baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
		enabled=1
		gpgcheck=1
		repo_gpgcheck=1
		gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
		EOF

	cat <<-EOF > /etc/sysconfig/kubelet
		KUBELET_EXTRA_ARGS="--cloud-provider=external"
		EOF

	setenforce 0
	sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

	yum install -y kubelet-$K8_RELEASE kubeadm-$K8_RELEASE kubectl-$K8_RELEASE --disableexcludes=kubernetes

	systemctl daemon-reload
	systemctl enable --now kubelet
}

install_docker(){
	yum install -y yum-utils device-mapper-persistent-data
	yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	yum -y install containerd.io-$CONTAINERD_RELEASE docker-ce-$DOCKER_RELEASE docker-ce-$DOCKER_RELEASE

	if test -d /etc/docker; then echo "continuing"; else mkdir /etc/docker; fi

	cat <<-EOF > /etc/docker/daemon.json
		{
		  "exec-opts": ["native.cgroupdriver=systemd"],
		  "log-driver": "json-file",
		  "log-opts": {
		    "max-size": "100m"
		  },
		  "storage-driver": "overlay2"
		}
		EOF

	mkdir -p /etc/systemd/system/docker.service.d

	systemctl daemon-reload
	systemctl enable docker
	systemctl restart docker
}

clean(){
	rm -f /tmp/common-provisioner.sh
}

main(){
	pre_dependencies

	network_config
	install_docker
	install_k8
	clean
}

main

