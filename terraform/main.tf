terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.pm_api_url
  pm_api_token_id = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure = true  # set false if you have valid SSL certs
}

# Variables declaration
variable "pm_api_url" {
  description = "The API URL for the Proxmox cluster"
  type        = string
}

variable "pm_api_token_id" {
  description = "The API token ID (format: user@pam!tokenid)"
  type        = string
  sensitive   = true
}

variable "pm_api_token_secret" {
  description = "The secret value for the API token"
  type        = string
  sensitive   = true
}

# Output a dynamic inventory file including k8s cluster machines
resource "local_file" "hosts_file" {
  content = templatefile("${path.module}/templates/kubespray-inventory.tpl", {
    masters = var.masters, workers = var.workers
  })

  filename = "${path.module}/kubespray-inventory.ini"
}
