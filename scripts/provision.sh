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
safe_apt -y install jq

PUBLIC_MAC=$(curl --silent 169.254.169.254/v1.json | jq -r '.interfaces[0].mac')
PUBLIC_NIC=$(ip -j link | jq --arg PUBLIC_MAC $PUBLIC_MAC '.[] | select(.address==$PUBLIC_MAC)' | jq -r .ifname)
INTERNAL_MAC=$(curl --silent 169.254.169.254/v1.json | jq -r '.interfaces[1].mac')
INTERNAL_NIC=$(ip -j link | jq --arg INTERNAL_MAC $INTERNAL_MAC '.[] | select(.address==$INTERNAL_MAC)' | jq -r .ifname)
INTERNAL_IP=$1
CONTROL_PLANE_PORTS=(6443 2379 2380 10250 10251 10252 8132 8133 9443)

if [ $(echo $HOSTNAME | grep controller) ]; then
    NODE_ROLE=controller
elif [ $(echo $HOSTNAME | grep worker) ]; then
    NODE_ROLE=worker
fi

case $NODE_ROLE in
    controller)
        for port in "${CONTROL_PLANE_PORTS[@]}"; do
            ufw allow $port
            ufw allow in on $INTERNAL_NIC
        done
    ;;
    worker)
        ufw allow 10250
        ufw allow 179
        ufw allow 9443
        ufw allow 4789/udp
        ufw allow 8132:8133/tcp
        ufw allow 30000:32767/tcp
        ufw allow in on $INTERNAL_NIC
    ;;
esac

ufw reload

cat <<-EOF > /etc/systemd/network/public.network
  [Match]
  MACAddress=$PUBLIC_MAC

  [Network]
  DHCP=yes
EOF

cat <<-EOF > /etc/systemd/network/private.network
  [Match]
  MACAddress=$INTERNAL_MAC

  [Network]
  Address=$INTERNAL_IP
EOF

echo "# For k0s"                            >> /etc/hosts
echo "$INTERNAL_IP             $(hostname)" >> /etc/hosts

systemctl enable systemd-networkd systemd-resolved
systemctl restart systemd-networkd systemd-resolved
systemctl disable networking
