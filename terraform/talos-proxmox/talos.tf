# add delay before talos resources start 
# TODO: REMOVE IT BUT IT IS BROKEN AND INCOSISTENT WITHOUT IT
resource "null_resource" "delay_before_talos" {
  depends_on = [proxmox_vm_qemu.control_plane_vm, proxmox_vm_qemu.worker_vm]

  provisioner "local-exec" {
    command = "sleep 90"
  }
}

resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version

  depends_on = [null_resource.delay_before_talos]
}

locals {
  api_port_k8s             = 6443
  cluster_api_host_private = "kube.${var.cluster_domain}"

  dummy_cluster_endpoint = "https://dummy.local:${local.api_port_k8s}"

  bootstrap_endpoint = proxmox_vm_qemu.control_plane_vm[local.control_plane_vms[0].name].default_ipv4_address
}

# control plane config
data "talos_machine_configuration" "control_plane" {
  for_each           = { for vm in local.control_plane_vms : vm.name => vm }
  talos_version      = var.talos_version
  cluster_name       = var.cluster_name
  cluster_endpoint   = var.cluster_endpoint
  kubernetes_version = var.kubernetes_version
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  docs               = false
  examples           = false

  depends_on = [null_resource.delay_before_talos]
}

# worker config
data "talos_machine_configuration" "worker" {
  for_each           = { for vm in local.worker_vms : vm.name => vm }
  talos_version      = var.talos_version
  cluster_name       = var.cluster_name
  cluster_endpoint   = var.cluster_endpoint
  kubernetes_version = var.kubernetes_version
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  docs               = false
  examples           = false

  depends_on = [null_resource.delay_before_talos]
}

# client config
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints = compact(
    var.output_mode_config_cluster_endpoint == "private_ip" ? (
      # Use private IPs in talosconfig
      local.control_plane_private_ipv4_list
    ) :

    var.output_mode_config_cluster_endpoint == "public_ip" ? (
      # Use public IPs in talosconfig
      local.control_plane_public_ipv4_list
    ) :

    var.output_mode_config_cluster_endpoint == "cluster_endpoint" ? (
      # Use cluster endpoint in talosconfig
      [local.cluster_api_host_public]
    ) : []
  )

  depends_on = [null_resource.delay_before_talos]
}

# apply control plane config
resource "talos_machine_configuration_apply" "control_plane" {
  for_each                    = { for vm in local.control_plane_vms : vm.name => vm }
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.control_plane[each.key].machine_configuration
  node                        = proxmox_vm_qemu.control_plane_vm[each.key].default_ipv4_address

  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = "/dev/sda"
        }
      }
    })
  ]

  depends_on = [null_resource.delay_before_talos]
}

# apply worker config
resource "talos_machine_configuration_apply" "worker" {
  for_each                    = { for vm in local.worker_vms : vm.name => vm }
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker[each.key].machine_configuration
  node                        = proxmox_vm_qemu.worker_vm[each.key].default_ipv4_address

  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = "/dev/sda"
        }
      }
    })
  ]

  depends_on = [null_resource.delay_before_talos]
}

# bootstrap control plane
resource "talos_machine_bootstrap" "this" {
  count                = var.control_plane_vm_count > 0 ? 1 : 0
  client_configuration = talos_machine_secrets.this.client_configuration
  depends_on           = [null_resource.delay_before_talos]
  endpoint             = local.bootstrap_endpoint
  node                 = local.bootstrap_endpoint

  timeouts = {
    create = "10m"
    update = "10m"
  }
}

# retrieve kubeconfig after bootstrapping control plane
resource "talos_cluster_kubeconfig" "this" {
  count                = var.control_plane_vm_count > 0 ? 1 : 0
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = proxmox_vm_qemu.control_plane_vm[local.control_plane_vms[0].name].default_ipv4_address
  depends_on           = [talos_machine_bootstrap.this, null_resource.delay_before_talos]
}
