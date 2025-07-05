variable "proxmox_token_secret" {
  description = "API token for Proxmox"
  type        = string
  sensitive   = true
}

variable "proxmox_host_ip" {
  description = "Proxmox hosting the VMs's ip address"
  type        = string
  default     = "192.168.0.113"
}

variable "proxmox_host" {
  description = "Proxmox host name hosting the VMs"
  type        = string
  default     = "proxmox"
}

variable "talos_template_vm_id" {
  description = "Proxmox VM ID of the Talos VM template"
  type        = string
  default     = "talos-0"
}

variable "gateway_ip" {
  description = "Gateway IP address"
  type        = string
  default     = "192.168.0.1"
}

variable "base_ip" {
  description = "Base IP address for Talos VMs"
  type        = string
  default     = "192.168.0"
}

variable "ip_range_start" {
  description = "Start of the IP range for Talos VMs (last octet)"
  type        = number
  default     = 200
}

variable "number_of_vms" {
  description = "Number of Talos VMs to create (control plane + workers)"
  type        = number
  default     = 3
}

variable "control_plane_vm_count" {
  description = "Number of control plane VMs"
  type        = number
  default     = 1
}

variable "control_plane_cpu" {
  description = "Number of CPU cores for control plane VMs"
  type        = number
  default     = 2
}

variable "control_plane_memory" {
  description = "Memory for control plane VMs in MB"
  type        = number
  default     = 4096
}


variable "worker_cpu" {
  description = "Number of CPU cores for worker VMs"
  type        = number
  default     = 3
}

variable "worker_memory" {
  description = "Memory for worker VMs in MB"
  type        = number
  default     = 6144
}
