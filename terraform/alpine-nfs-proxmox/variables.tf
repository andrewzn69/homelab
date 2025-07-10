variable "proxmox_host_ip" {
  description = "IP or hostname of the Proxmox server"
  type        = string
}

variable "proxmox_token_id" {
  description = "Proxmox API token ID"
  type        = string
}

variable "proxmox_token_secret" {
  description = "API token for Proxmox"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Allow insecure TLS (self signed certs)"
  type        = bool
  default     = true
}

variable "node_name" {
  description = "Proxmox node to deploy the container on"
  type        = string
}

variable "lxc_hostname" {
  description = "Hostname for the LXC container"
  type        = string
}

variable "lxc_password" {
  description = "Root password for the LXC container"
  type        = string
  sensitive   = true
}

variable "lxc_template" {
  description = "Alpine template storage location"
  type        = string
}

variable "lxc_storage" {
  description = "Storage pool for the container's root disk"
  type        = string
}

variable "lxc_disk_size" {
  description = "Root disk size"
  type        = string
  default     = "4G"
}

variable "lxc_memory" {
  description = "Memory in MB"
  type        = number
  default     = 512
}

variable "lxc_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 1
}

variable "lxc_network_bridge" {
  description = "Network bridge for the container"
  type        = string
}

variable "lxc_ip" {
  description = "Static ipv4 with cidr"
  type        = string
}

variable "lxc_gateway" {
  description = "gateway for the container"
  type        = string
}

variable "ssh_public_keys" {
  description = "ssh public keys for root"
  type        = string
}
