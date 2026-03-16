# This file is managed by Ansible, manual changes will be overwritten.

vms = {
  "t-cp1.pipenberg.eu" = {
    memory = "4096"
    cpus = "4"
    ip = "172.16.90.11"
    network_cidr = "24"
    dns_server1 = "172.16.90.1"
    dns_server2 = "172.16.90.2"
    ntp_servers = ["172.16.90.1"]
    gw_ip = "172.16.90.1"
    root_disk_size = "102400"    
    "pve" = {
      node_name = "a-hv"
      vm_storage = "ssd"
      template_storage = "local"
    },
    labels = {
          "topology.kubernetes.io/zone" = "a"
        },
    "talos" = {
      node_role = "control-plane",
      enable_systemdisk_encryption = true
    }
  },
  "t-cp2.pipenberg.eu" = {
    memory = "4096"
    cpus = "4"
    ip = "172.16.90.12"
    network_cidr = "24"
    dns_server1 = "172.16.90.1"
    dns_server2 = "172.16.90.2"
    ntp_servers = ["172.16.90.1"]
    gw_ip = "172.16.90.1"
    root_disk_size = "102400"
        
    "pve" = {
      node_name = "b-hv"
      vm_storage = "ssd"
      template_storage = "local"
    },
    
    labels = {
          "topology.kubernetes.io/zone" = "b"
        },
    "talos" = {
      node_role = "control-plane",
      enable_systemdisk_encryption = true
    }
  },
  "t-cp3.pipenberg.eu" = {
    memory = "4096"
    cpus = "4"
    ip = "172.16.90.13"
    network_cidr = "24"
    dns_server1 = "172.16.90.1"
    dns_server2 = "172.16.90.2"
    ntp_servers = ["172.16.90.1"]
    gw_ip = "172.16.90.1"
    root_disk_size = "102400"
        
    "pve" = {
      node_name = "c-hv"
      vm_storage = "ssd"
      template_storage = "local"
    },    
    labels = {
          "topology.kubernetes.io/zone" = "c"
        },
    "talos" = {
      node_role = "control-plane",
      enable_systemdisk_encryption = true
    }
  },
  "t-w1.pipenberg.eu" = {
    memory = "8192"
    cpus = "4"
    ip = "172.16.90.14"
    network_cidr = "24"
    dns_server1 = "172.16.90.1"
    dns_server2 = "172.16.90.2"
    ntp_servers = ["172.16.90.1"]
    gw_ip = "172.16.90.1"
    root_disk_size = "102400"
    data_disk1_size = "153600"
        
    "pve" = {
      node_name = "a-hv"
      vm_storage = "ssd"
      template_storage = "local"
    },
    labels = {
          "topology.kubernetes.io/zone" = "a",
          "node.longhorn.io/create-default-disk" = true,
        },
    "talos" = {
      node_role = "worker",
      enable_systemdisk_encryption = true
    }
    "kubernetes" = {
      infra_node = true
    }
  },
  "t-w2.pipenberg.eu" = {
    memory = "8192"
    cpus = "4"
    ip = "172.16.90.15"
    network_cidr = "24"
    dns_server1 = "172.16.90.1"
    dns_server2 = "172.16.90.2"
    ntp_servers = ["172.16.90.1"]
    gw_ip = "172.16.90.1"
    root_disk_size = "102400"  
    data_disk1_size = "153600"    
    "pve" = {
      node_name = "b-hv"
      vm_storage = "ssd"
      template_storage = "local"
    },
    labels = {
          "topology.kubernetes.io/zone" = "b",
          "node.longhorn.io/create-default-disk" = true
        },
    "talos" = {
      node_role = "worker"
      enable_systemdisk_encryption = true
    }
    "kubernetes" = {
      infra_node = true
    }
  },
  "t-w3.pipenberg.eu" = {
    memory = "8192"
    cpus = "4"
    ip = "172.16.90.16"
    network_cidr = "24"
    dns_server1 = "172.16.90.1"
    dns_server2 = "172.16.90.2"
    ntp_servers = ["172.16.90.1"]
    gw_ip = "172.16.90.1"
    root_disk_size = "102400"  
    data_disk1_size = "153600"   
    "pve" = {
      node_name = "c-hv"
      vm_storage = "ssd"
      template_storage = "local"
    },
    
    labels = {
          "topology.kubernetes.io/zone" = "c",
          "node.longhorn.io/create-default-disk" = true,
        },
    "talos" = {
      node_role = "worker"
      enable_systemdisk_encryption = true
    }
    "kubernetes" = {
      infra_node = true
    }
  },
  "t-w4.pipenberg.eu" = {
    memory = "8192"
    cpus = "4"
    ip = "172.16.90.17"
    network_cidr = "24"
    dns_server1 = "172.16.90.1"
    dns_server2 = "172.16.90.2"
    ntp_servers = ["172.16.90.1"]
    gw_ip = "172.16.90.1"
    root_disk_size = "102400"    
    "pve" = {
      node_name = "a-hv"
      vm_storage = "ssd"
      template_storage = "local"
    },
    
    labels = {
          "topology.kubernetes.io/zone" = "a",
          "node.longhorn.io/create-default-disk" = false
        },
    "talos" = {
      node_role = "worker"
      enable_systemdisk_encryption = true
    }
  },
  "t-w5.pipenberg.eu" = {
    memory = "8192"
    cpus = "4"
    ip = "172.16.90.18"
    network_cidr = "24"
    dns_server1 = "172.16.90.1"
    dns_server2 = "172.16.90.2"
    ntp_servers = ["172.16.90.1"]
    gw_ip = "172.16.90.1"
    root_disk_size = "102400"    
    "pve" = {
      node_name = "b-hv"
      vm_storage = "ssd"
      template_storage = "local"
    },
    
    labels = {
          "topology.kubernetes.io/zone" = "b",
          "node.longhorn.io/create-default-disk" = false
        },
    "talos" = {
      node_role = "worker"
      enable_systemdisk_encryption = true
    }
  },
  "t-w6.pipenberg.eu" = {
    memory = "8192"
    cpus = "4"
    ip = "172.16.90.19"
    network_cidr = "24"
    dns_server1 = "172.16.90.1"
    dns_server2 = "172.16.90.2"
    ntp_servers = ["172.16.90.1"]
    gw_ip = "172.16.90.1"
    root_disk_size = "102400"
        
    "pve" = {
      node_name = "c-hv"
      vm_storage = "ssd"
      template_storage = "local"
    },
    labels = {
          "topology.kubernetes.io/zone" = "c",
          "node.longhorn.io/create-default-disk" = false
        },
    "talos" = {
      node_role = "worker"
      enable_systemdisk_encryption = true
    }
  }
}
### TOFU ###
tofu_s3_backend_bucket = "tclu-tofu"
tofu_s3_backend_key = "tclu/state/tofu.tfstate"
### Talos/K8S variables ###
talos_k8s_cluster_name = "T-CLU"
talos_k8s_cluster_endpoint = "https://t-clu.pipenberg.eu:6443"
talos_k8s_cluster_vip = "172.16.90.10"
image_registry_mirror = "https://registry.pipenberg.eu"
talos_version = "1.12.4"
talos_image = "factory.talos.dev/nocloud-installer-secureboot/2f3bd6bfdf61c500274caf61a67b85c1789d88e1c7afc9bc60f2113d380afde5:v1.12.4"
k8s_version = "1.34.5"
k8s_host_network = "172.16.90.0/24"
mgmt_network = "172.16.88.0/24"
### Cilium variables ###
cilium_version = "1.18.7"
cilium_peer_router_ip = "172.16.90.1"
cilium_peer_router_asn = "64500"
### Flux variables ###
git_repo = "https://github.com/opipenbe/pilvelaevastik.git"
