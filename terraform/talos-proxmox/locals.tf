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
