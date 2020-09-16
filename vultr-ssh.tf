resource "vultr_ssh_key" "provisioner" {
  name    = "k8-provisioner"
  ssh_key = trimspace(file("~/.ssh/id_rsa.pub"))
}

