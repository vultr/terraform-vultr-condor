#!/bin/bash

set -euxo posix

if [ $# -ne 3 ]; then
	echo "common-provisioner.sh requires 3 parameters"
	exit 1
fi

yum -y update
yum -y install jq curl

INSTANCE_METADATA=$(curl --silent http://169.254.169.254/v1.json)
PRIVATE_IP=$(echo $INSTANCE_METADATA | jq -r .interfaces[1].ipv4.address)
DOCKER_RELEASE="$1"
CONTAINERD_RELEASE="$2"
K8_RELEASE=$(echo $3 | sed 's/v//' | sed 's/$/-00/')

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
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

	cat <<-EOF > /etc/apt/sources.list.d/kubernetes.list
		deb https://apt.kubernetes.io/ kubernetes-xenial main
		EOF

	apt -y update
	apt -y install kubelet=$K8_RELEASE kubeadm=$K8_RELEASE kubectl=$K8_RELEASE
	apt-mark hold kubelet kubeadm kubectl

	cat <<-EOF > /etc/default/kubelet
		KUBELET_EXTRA_ARGS="--cloud-provider=external"
		EOF
}

install_docker(){
	apt -y update
	apt -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common

	curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

	cat <<-EOF > /etc/apt/sources.list.d/docker.list
		deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable
		EOF

	apt -y update
	apt -y install containerd.io=$CONTAINERD_RELEASE docker-ce=$DOCKER_RELEASE docker-ce-cli=$DOCKER_RELEASE

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
	install_k8
	install_docker
	clean
}

main

