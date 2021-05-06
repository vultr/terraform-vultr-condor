#!/usr/bin/env bash
set -euxo posix

safe_apt(){
	while fuser /var/{lib/{dpkg,apt/lists},cache/apt/archives}/lock >/dev/null 2>&1 ; do
		echo "Waiting for apt lock..."
		sleep 1
	done
	apt "$@"
}

safe_apt -y update
safe_apt -y install jq gnupg2

INSTANCE_METADATA=$(curl --silent http://169.254.169.254/v1.json)
PRIVATE_IP=$(echo $INSTANCE_METADATA | jq -r .interfaces[1].ipv4.address)
PUBLIC_MAC=$(curl --silent 169.254.169.254/v1.json | jq -r '.interfaces[] | select(.["network-type"]=="public") | .mac')
PRIVATE_MAC=$(curl --silent 169.254.169.254/v1.json | jq -r '.interfaces[] | select(.["network-type"]=="private") | .mac')
HOSTNAME=$(curl --silent 169.254.169.254/v1.json | jq -r '.hostname')

CONTAINERD_RELEASE="${CONTAINERD_RELEASE}"
K8_VERSION="${K8_VERSION}"
PRE_PROVISIONED=${PRE_PROVISIONED}
FILES_TO_CLEAN="/tmp/condor-provision.sh"

set_hostname(){
	echo $HOSTNAME > /etc/hostname
	hostnamectl set-hostname $HOSTNAME
}

system_config(){
	cat <<-EOF > /etc/modules-load.d/containerd.conf
		overlay
		br_netfilter
		EOF

	cat <<-EOF > /etc/sysctl.d/99-kubernetes-cri.conf
		net.bridge.bridge-nf-call-iptables  = 1
		net.ipv4.ip_forward                 = 1
		net.bridge.bridge-nf-call-ip6tables = 1
		EOF

	modprobe overlay
	modprobe br_netfilter
	sysctl --system
}

network_config(){
	cat <<-EOF > /etc/systemd/network/public.network
		[Match]
		Name=ens3

		[Network]
		DHCP=yes
		EOF

	cat <<-EOF > /etc/systemd/network/private.network
		[Match]
		Name=ens7

		[Network]
		Address=$PRIVATE_IP
		EOF

	systemctl enable systemd-networkd systemd-resolved
	systemctl restart systemd-networkd systemd-resolved
	systemctl disable networking
}

install_containerd(){
	safe_apt -y update
	safe_apt -y install apt-transport-https ca-certificates curl software-properties-common

	curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -

    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

	safe_apt -y update
	safe_apt -y install containerd.io=$CONTAINERD_RELEASE
}

install_k8(){
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

	cat <<-EOF > /etc/apt/sources.list.d/kubernetes.list
		deb https://apt.kubernetes.io/ kubernetes-xenial main
		EOF

	safe_apt -y update
	safe_apt -y install kubelet=$K8_VERSION kubeadm=$K8_VERSION kubectl=$K8_VERSION
	apt-mark hold kubelet kubeadm kubectl

	cat <<-EOF > /etc/default/kubelet
		KUBELET_EXTRA_ARGS="--cloud-provider=external"
		EOF
}

clean(){
	rm -f $FILES_TO_CLEAN
}

main(){
	if [ "$PRE_PROVISIONED" = true ]; then
	    set_hostname
	    network_config
	else
		system_config
		network_config
		install_containerd
		install_k8
	fi

	clean
}

main
