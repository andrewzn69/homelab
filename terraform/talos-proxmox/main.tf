terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc01"
    }
  }
  required_version = ">=1.7.5"
}
provider "proxmox" {
  pm_api_url          = "https://${var.proxmox_host_ip}:8006/api2/json"
  pm_api_token_id     = "root@pam!terraform"
  pm_api_token_secret = var.proxmox_token_secret
  pm_tls_insecure     = true
}

locals {
  worker_vm_count = var.number_of_vms - var.control_plane_vm_count

  control_plane_vms = [
    for i in range(var.control_plane_vm_count) : {
      name   = "talos-controlplane-${i + 1}"
      role   = "control-plane"
      cpu    = var.control_plane_cpu
      memory = var.control_plane_memory
      ip     = "${var.base_ip}.${var.ip_range_start + i}"
    }
  ]

  worker_vms = [
    for i in range(local.worker_vm_count) : {
      name   = "talos-worker-${i + 1}"
      cpu    = var.worker_cpu
      memory = var.worker_memory
      role   = "worker"
      ip     = "${var.base_ip}.${var.ip_range_start + var.control_plane_vm_count + i}"
    }
  ]

  all_vms = concat(local.control_plane_vms, local.worker_vms)
}

# create control planes
resource "proxmox_vm_qemu" "control_plane_vm" {
  for_each = { for vm in local.control_plane_vms : vm.name => vm }

  name        = each.value.name
  target_node = var.proxmox_host
  clone       = var.talos_template_vm_id
  full_clone  = true
  agent       = 1
  bootdisk    = "scsi0"
  scsihw      = "virtio-scsi-pci"
  onboot      = "true"
  ipconfig0   = "ip=${each.value.ip}/24,gw=${var.gateway_ip}"

  cpu {
    cores = each.value.cpu
  }
  memory = each.value.memory

  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = "10G"
        }
      }
      scsi1 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
    ide {
      ide2 {
        cdrom {
          iso = "local:iso/talos-nocloud-amd64.iso"
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  lifecycle {
    ignore_changes = [
      disk,
      network,
      desc
    ]
    prevent_destroy = false
  }
}

# create worker nodes
resource "proxmox_vm_qemu" "worker_vm" {
  for_each = { for vm in local.worker_vms : vm.name => vm }

  name        = each.value.name
  target_node = var.proxmox_host
  clone       = var.talos_template_vm_id
  full_clone  = true
  agent       = 1
  bootdisk    = "scsi0"
  scsihw      = "virtio-scsi-pci"
  onboot      = true
  ipconfig0   = "ip=${each.value.ip}/24,gw=${var.gateway_ip}"

  cpu {
    cores = each.value.cpu
  }
  memory = each.value.memory

  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = "10G"
        }
      }
      scsi1 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
    ide {
      ide2 {
        cdrom {
          iso = "local:iso/talos-nocloud-amd64.iso"
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  lifecycle {
    ignore_changes = [
      disk,
      network,
      desc
    ]
    prevent_destroy = false
  }
}
