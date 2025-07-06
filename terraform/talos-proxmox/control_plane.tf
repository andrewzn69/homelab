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
    prevent_destroy = true
  }
}
