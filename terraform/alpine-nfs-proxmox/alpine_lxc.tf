resource "proxmox_lxc" "alpine_nfs" {
  hostname     = var.lxc_hostname
  target_node  = var.node_name
  ostemplate   = var.lxc_template
  password     = var.lxc_password
  start        = true
  unprivileged = true

  cores  = var.lxc_cores
  memory = var.lxc_memory

  rootfs {
    storage = var.lxc_storage
    size    = var.lxc_disk_size
  }

  network {
    name   = "eth0"
    bridge = var.lxc_network_bridge
    ip     = var.lxc_ip
    gw     = var.lxc_gateway
  }

  ssh_public_keys = var.ssh_public_keys
}
