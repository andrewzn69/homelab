provider "proxmox" {
  pm_api_url          = "https://${var.proxmox_host_ip}:8006/api2/json"
  pm_api_token_id     = "root@pam!terraform"
  pm_api_token_secret = var.proxmox_token_secret
  pm_tls_insecure     = true
}
