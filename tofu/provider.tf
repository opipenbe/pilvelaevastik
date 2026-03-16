terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.10.1"
    }
    proxmox = {
      source = "bpg/proxmox"
      version = "0.97.1"
    }
    helm = {
      source = "hashicorp/helm"
      version = "3.1.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "3.0.1"
    }
    flux = {
      source = "fluxcd/flux"
      version = "1.8.3"
    }
    time = {
      source = "hashicorp/time"
      version = "0.13.1"
    }
  }
  backend "s3" {
    bucket = var.tofu_s3_backend_bucket
    key = var.tofu_s3_backend_key
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style = true
  }
}

provider "proxmox" {
  endpoint = var.pve_url
}

provider "talos" {
}


provider "helm" {
  kubernetes = {
      host = module.talos.kubernetes_client_configuration.host
      cluster_ca_certificate = base64decode(module.talos.kubernetes_client_configuration.ca_certificate)
      client_certificate = base64decode(module.talos.kubernetes_client_configuration.client_certificate)
      client_key = base64decode(module.talos.kubernetes_client_configuration.client_key)
  }
}

provider "kubernetes" {
  host = module.talos.kubernetes_client_configuration.host
  cluster_ca_certificate = base64decode(module.talos.kubernetes_client_configuration.ca_certificate)
  client_certificate = base64decode(module.talos.kubernetes_client_configuration.client_certificate)
  client_key = base64decode(module.talos.kubernetes_client_configuration.client_key)
}

provider "flux" {
  kubernetes = {
      host = module.talos.kubernetes_client_configuration.host
      cluster_ca_certificate = base64decode(module.talos.kubernetes_client_configuration.ca_certificate)
      client_certificate = base64decode(module.talos.kubernetes_client_configuration.client_certificate)
      client_key = base64decode(module.talos.kubernetes_client_configuration.client_key)
  }
  git = {
    url = var.git_repo
    http = {
      username = "git" # This can be any string when using a personal access token
      password = var.git_pat_token
    }
  }
}
