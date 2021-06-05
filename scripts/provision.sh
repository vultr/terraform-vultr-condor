#!/usr/bin/env bash
set -euxo posix

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
            ufw allow in on ens7
        done
    ;;
    worker)
        ufw allow 10250
        ufw allow 179
        ufw allow 9443
        ufw allow 4789/udp
        ufw allow 8132:8133/tcp
        ufw allow 30000:32767/tcp
        ufw allow in on ens7
    ;;
esac

ufw reload

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
  Address=$INTERNAL_IP
EOF

echo "# For k0s"                            >> /etc/hosts
echo "$INTERNAL_IP             $(hostname)" >> /etc/hosts

systemctl enable systemd-networkd systemd-resolved
systemctl restart systemd-networkd systemd-resolved
systemctl disable networking
