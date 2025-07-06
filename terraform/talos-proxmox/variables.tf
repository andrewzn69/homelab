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

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
  default     = "cafe"
}

variable "cluster_domain" {
  description = "The domain name of the cluster"
  type        = string
  default     = "cafe.local"
}

variable "cluster_api_host" {
  description = <<EOF
    Optional. A stable DNS hostname for the public Kubernetes API endpoint (e.g., `kube.mydomain.com`).
    If set, you MUST configure a DNS A record for this hostname pointing to your desired public entrypoint (e.g., Floating IP, Load Balancer IP).
    This hostname will be embedded in the cluster's certificates (SANs).
    If not set, the generated kubeconfig/talosconfig will use an IP address based on `output_mode_config_cluster_endpoint`.
    Internal cluster communication often uses `kube.[cluster_domain]`, which is handled automatically via /etc/hosts if `enable_alias_ip = true`.
  EOF
  type        = string
  default     = null
}

variable "cluster_endpoint" {
  description = "The IP address of the cluster API endpoint"
  type        = string
  default     = "https://192.168.0.200:6443"
}

variable "talos_version" {
  description = "The version of talos features to use in generated machine configurations"
  type        = string
  default     = "v1.10.4"
}

variable "kubernetes_version" {
  description = <<EOF
    The Kubernetes version to use. If not set, the latest version supported by Talos is used: https://www.talos.dev/v1.7/introduction/support-matrix/
  EOF
  type        = string
  default     = "1.30.3"
}

variable "output_mode_config_cluster_endpoint" {
  description = "How to configure the cluster endpoint in talosconfig: 'private_ip', 'public_ip' or 'cluster_endpoint'"
  type        = string
  default     = "private_ip"
  validation {
    condition     = contains(["private_ip", "public_ip", "cluster_endpoint"], var.output_mode_config_cluster_endpoint)
    error_message = "output_mode_config_cluster_endpoint must be one of: private_ip, public_ip, cluster_endpoint"
  }
}
