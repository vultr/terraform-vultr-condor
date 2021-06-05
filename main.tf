terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.3.0"
    }
  }
}

locals {
  cluster_name = "${var.cluster_name}-${random_id.cluster.hex}"
  public_keys  = concat([vultr_ssh_key.provisioner.id], vultr_ssh_key.extra_public_keys.*.id)
}

data "vultr_os" "cluster" {
  filter {
    name   = "name"
    values = [var.cluster_os]
  }
}

resource "random_id" "cluster" {
  byte_length = 8
}

resource "vultr_ssh_key" "provisioner" {
  name    = "Provisioner public key for k0s cluster ${random_id.cluster.hex}"
  ssh_key = var.provisioner_public_key
}

resource "vultr_ssh_key" "extra_public_keys" {
  count   = length(var.extra_public_keys)
  name    = "Public key for k0s cluster ${random_id.cluster.hex}"
  ssh_key = var.extra_public_keys[count.index]
}

resource "vultr_private_network" "cluster" {
  description    = "Private Network for k0s cluster ${random_id.cluster.hex}"
  region         = var.region
  v4_subnet      = element(split("/", var.node_subnet), 0)
  v4_subnet_mask = element(split("/", var.node_subnet), 1)
}

resource "vultr_load_balancer" "control_plane_ha" {
  region              = var.region
  label               = "HA Control Plane Load Balancer for k0s cluster ${random_id.cluster.hex}"
  balancing_algorithm = var.ha_lb_algorithm
  private_network     = vultr_private_network.cluster.id

  forwarding_rules {
    frontend_protocol = "tcp"
    frontend_port     = 6443
    backend_protocol  = "tcp"
    backend_port      = 6443
  }

  forwarding_rules {
    frontend_protocol = "tcp"
    frontend_port     = 8132
    backend_protocol  = "tcp"
    backend_port      = 8132
  }

  forwarding_rules {
    frontend_protocol = "tcp"
    frontend_port     = 8133
    backend_protocol  = "tcp"
    backend_port      = 8133
  }

  forwarding_rules {
    frontend_protocol = "tcp"
    frontend_port     = 9443
    backend_protocol  = "tcp"
    backend_port      = 9443
  }

  health_check {
    port                = "6443"
    protocol            = "tcp"
    response_timeout    = var.ha_lb_health_response_timeout
    unhealthy_threshold = var.ha_lb_health_unhealthy_threshold
    check_interval      = var.ha_lb_health_check_interval
    healthy_threshold   = var.ha_lb_health_healthy_threshold
  }

  attached_instances = vultr_instance.control_plane.*.id
}

resource "vultr_firewall_group" "cluster" {
  description = "Firewall group for k0s cluster ${random_id.cluster.hex}"
}

resource "vultr_instance" "control_plane" {
  count               = var.controller_count
  plan                = var.controller_plan
  hostname            = "${local.cluster_name}-controller-${count.index}"
  label               = "${local.cluster_name}-controller-${count.index}"
  region              = var.region
  os_id               = data.vultr_os.cluster.id
  firewall_group_id   = vultr_firewall_group.cluster.id
  private_network_ids = [vultr_private_network.cluster.id]
  ssh_key_ids         = local.public_keys
  enable_ipv6         = var.enable_ipv6
  activation_email    = var.activation_email
  ddos_protection     = var.ddos_protection
  tag                 = var.tag

  connection {
    type = "ssh"
    user = "root"
    host = self.main_ip
  }

  provisioner "file" {
    source      = "${path.module}/scripts/provision.sh"
    destination = "/tmp/provision.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision.sh",
      "/tmp/provision.sh ${self.internal_ip}",
      "rm -f /tmp/provision.sh"
    ]
  }
}

resource "vultr_instance" "worker" {
  count               = var.worker_count
  plan                = var.worker_plan
  hostname            = "${local.cluster_name}-worker-${count.index}"
  label               = "${local.cluster_name}-worker-${count.index}"
  region              = var.region
  os_id               = data.vultr_os.cluster.id
  firewall_group_id   = vultr_firewall_group.cluster.id
  private_network_ids = [vultr_private_network.cluster.id]
  ssh_key_ids         = local.public_keys
  enable_ipv6         = var.enable_ipv6
  activation_email    = var.activation_email
  ddos_protection     = var.ddos_protection
  tag                 = var.tag

  connection {
    type = "ssh"
    user = "root"
    host = self.main_ip
  }

  provisioner "file" {
    source      = "${path.module}/scripts/provision.sh"
    destination = "/tmp/provision.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision.sh",
      "/tmp/provision.sh ${self.internal_ip}",
      "rm -f /tmp/provision.sh"
    ]
  }
}

resource "null_resource" "k0s" {
  depends_on = [
    vultr_load_balancer.control_plane_ha,
    vultr_instance.control_plane,
    vultr_instance.worker
  ]

  triggers = {
    k0s_version            = var.k0s_version
    controller_count       = var.controller_count
    konnectivity_version   = var.konnectivity_version
    metrics_server_version = var.metrics_server_version
    kube_proxy_version     = var.kube_proxy_version
    core_dns_version       = var.core_dns_version
    calico_version         = var.calico_version
    enable_vultr           = var.enable_vultr
    ccm_version            = var.vultr_ccm_version
    csi_version            = var.vultr_csi_version
    ccm_chart_version      = var.ccm_chart_version
    csi_chart_version      = var.csi_chart_version
  }

  provisioner "local-exec" {
    command = <<-EOT
      cat <<-EOF > k0sctl.yaml
        apiVersion: k0sctl.k0sproject.io/v1beta1
        kind: Cluster
        metadata:
          name: ${local.cluster_name}
        spec:
          hosts:
          %{for host in vultr_instance.control_plane}
          - role: controller
            installFlags:
            - --enable-cloud-provider=true
            privateAddress: ${host.internal_ip}
            ssh:
              address: ${host.main_ip}
              user: root
              port: 22
          %{endfor~}
          %{for host in vultr_instance.worker}
          - role: worker
            installFlags:
            - --enable-cloud-provider=true
            privateAddress: ${host.internal_ip}
            ssh:
              address: ${host.main_ip}
              user: root
              port: 22
          %{endfor}
          k0s:
            version: ${var.k0s_version}
            config:
              apiVersion: k0s.k0sproject.io/v1beta1
              kind: Cluster
              metadata:
                name: ${local.cluster_name}
              spec:
                telemetry:
                  enabled: false
                api:
                  port: 6443
                  k0sApiPort: 9443
                  externalAddress: ${vultr_load_balancer.control_plane_ha.ipv4}
                  address: ${vultr_load_balancer.control_plane_ha.ipv4}
                  sans:
                    - ${vultr_load_balancer.control_plane_ha.ipv4}
                network:
                  podCIDR: ${var.pod_cidr}
                  serviceCIDR: ${var.svc_cidr}
                  provider: calico
                  calico:
                    wireguard: ${var.calico_wireguard}
                podSecurityPolicy:
                  defaultPolicy: ${var.pod_sec_policy}
                images:
                  konnectivity:
                    image: us.gcr.io/k8s-artifacts-prod/kas-network-proxy/proxy-agent
                    version: ${var.konnectivity_version}
                  metricsserver:
                    image: gcr.io/k8s-staging-metrics-server/metrics-server
                    version: ${var.metrics_server_version}
                  kubeproxy:
                    image: k8s.gcr.io/kube-proxy
                    version: ${var.kube_proxy_version}
                  coredns:
                    image: docker.io/coredns/coredns
                    version: ${var.core_dns_version}
                  calico:
                    cni:
                      image: calico/cni
                      version: ${var.calico_version}
      EOF

      k0sctl apply

EOT
  }
}

resource "null_resource" "vultr_extensions" {
  triggers = {
    api_key     = var.cluster_vultr_api_key
    ccm_version = var.vultr_ccm_version
    csi_version = var.vultr_csi_version
  }

  connection {
    type = "ssh"
    user = "root"
    host = vultr_instance.control_plane[0].main_ip
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /var/lib/k0s/manifests/vultr"
    ]
  }

  provisioner "file" {
    content     = <<-EOT
      apiVersion: v1
      kind: Secret
      metadata:
        name: vultr-ccm
        namespace: kube-system
      stringData:
        api-key: "${var.cluster_vultr_api_key}"
        region: "${var.region}"
      ---
      apiVersion: v1
      kind: Secret
      metadata:
        name: vultr-csi
        namespace: kube-system
      stringData:
        api-key: "${var.cluster_vultr_api_key}"
      ---
    EOT
    destination = "/var/lib/k0s/manifests/vultr/vultr-api-key.yaml"
  }

  provisioner "file" {
    content     = <<-EOT
      apiVersion: v1
      kind: ServiceAccount
      metadata:
        name: vultr-ccm
        namespace: kube-system
      ---
      apiVersion: rbac.authorization.k8s.io/v1
      kind: ClusterRole
      metadata:
        annotations:
          rbac.authorization.kubernetes.io/autoupdate: "true"
        name: system:vultr-ccm
      rules:
        - apiGroups:
            - ""
          resources:
            - events
          verbs:
            - create
            - patch
            - update
        - apiGroups:
            - ""
          resources:
            - nodes
          verbs:
            - '*'
        - apiGroups:
            - ""
          resources:
            - nodes/status
          verbs:
            - patch
        - apiGroups:
            - ""
          resources:
            - services
          verbs:
            - list
            - patch
            - update
            - watch
        - apiGroups:
            - ""
          resources:
            - services/status
          verbs:
            - list
            - patch
            - update
            - watch
        - apiGroups:
            - ""
          resources:
            - serviceaccounts
          verbs:
            - create
            - get
        - apiGroups:
            - ""
          resources:
            - persistentvolumes
          verbs:
            - get
            - list
            - update
            - watch
        - apiGroups:
            - ""
          resources:
            - endpoints
          verbs:
            - create
            - get
            - list
            - watch
            - update
        - apiGroups:
            - coordination.k8s.io
          resources:
            - leases
          verbs:
            - create
            - get
            - list
            - watch
            - update
        - apiGroups:
            - ""
          resources:
            - secrets
          verbs:
            - get
            - list
            - watch
      ---
      kind: ClusterRoleBinding
      apiVersion: rbac.authorization.k8s.io/v1
      metadata:
        name: system:vultr-ccm
      roleRef:
        apiGroup: rbac.authorization.k8s.io
        kind: ClusterRole
        name: system:vultr-ccm
      subjects:
        - kind: ServiceAccount
          name: vultr-ccm
          namespace: kube-system
      ---
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: vultr-ccm
        labels:
          app: vultr-ccm
        namespace: kube-system
      spec:
        replicas: 1
        selector:
          matchLabels:
            app: vultr-ccm
        template:
          metadata:
            labels:
              app: vultr-ccm
          spec:
            serviceAccountName: vultr-ccm
            tolerations:
              - key: "CriticalAddonsOnly"
                operator: "Exists"
              - key: "node.cloudprovider.kubernetes.io/uninitialized"
                value: "true"
                effect: "NoSchedule"
              - key: node.kubernetes.io/not-ready
                operator: Exists
                effect: NoSchedule
              - key: node.kubernetes.io/unreachable
                operator: Exists
                effect: NoSchedule
            hostNetwork: true
            containers:
              - image: vultr/vultr-cloud-controller-manager:${var.vultr_ccm_version}
                imagePullPolicy: Always
                name: vultr-cloud-controller-manager
                command:
                  - "/vultr-cloud-controller-manager"
                  - "--cloud-provider=vultr"
                  - "--allow-untagged-cloud=true"
                  - "--authentication-skip-lookup=true"
                  - "--v=3"
                env:
                  - name: VULTR_API_KEY
                    valueFrom:
                      secretKeyRef:
                        name: vultr-ccm
                        key: api-key
    EOT
    destination = "/var/lib/k0s/manifests/vultr/vultr-ccm-${var.vultr_ccm_version}.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "wget https://raw.githubusercontent.com/vultr/vultr-csi/master/docs/releases/${var.vultr_csi_version}.yml -O /var/lib/k0s/manifests/vultr/csi-${var.vultr_csi_version}.yml"
    ]
  }
}
