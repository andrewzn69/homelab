output "container_id" {
  value = proxmox_lxc.alpine_nfs.id
}

output "container_ip" {
  value = var.lxc_ip
}

output "container_hostname" {
  value = var.lxc_hostname
}
