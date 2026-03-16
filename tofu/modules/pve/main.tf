terraform {
    required_providers {
        proxmox = {
        source = "bpg/proxmox"
        }
    }
}

resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  for_each = {
    for name, vm in var.vms :
    name => vm
    if vm.pve != null
  }
  content_type            = "iso"
  datastore_id            = each.value.pve.template_storage
  node_name               = each.value.pve.node_name
  file_name               = "talos_template.img"
  url = "https://factory.talos.dev/image/${replace(regex(".*?/nocloud-installer-secureboot/(.*)", var.talos_image)[0], ":", "/")}/nocloud-amd64-secureboot.raw.gz"
  decompression_algorithm = "gz"
  overwrite               = false
  overwrite_unmanaged     = true
}

resource "proxmox_virtual_environment_vm" "vm" {
  for_each = {
    for name, vm in var.vms :
    name => vm
    if vm.pve != null
  }
  name        = each.key
  description = "Managed by OpenTofu"
  tags        = ["${each.key}"]
  node_name   = each.value.pve.node_name
  on_boot     = true

  cpu {
    cores = each.value.cpus
    #type = "x86-64-v2-AES"
    type = "host"
  }

  memory {
    dedicated = each.value.memory
    floating  = each.value.memory
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
    vlan_id = 26
  }

  disk {
    datastore_id = each.value.pve.vm_storage
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image[each.key].id
    file_format  = "raw"
    interface    = "virtio0"
    cache        = "writethrough"
    # Convert size as Proxmox expects in GB
    size         = each.value.root_disk_size / 1024
  }

  # Add a data disk
  dynamic "disk" {
    for_each = each.value.data_disk1_size != null && each.value.data_disk1_size > 0 ? [each.value] : []
    content {
      datastore_id = each.value.pve.vm_storage
      file_format  = "qcow2"
      interface    = "virtio1" # Use a different interface for the data disk
      cache        = "writeback"
      size         = each.value.data_disk1_size / 1024 # Convert size to GB
    }
  }

  efi_disk {
    type = "4m"
    datastore_id = each.value.pve.vm_storage
    pre_enrolled_keys = false
  }

  tpm_state {
    datastore_id = each.value.pve.vm_storage
  }

  operating_system {
    type = "l26"
  }

  bios = "ovmf"

  machine = "q35"

  rng {
    source = "/dev/urandom"
  }

  initialization {
    datastore_id = each.value.pve.vm_storage
    ip_config {
      ipv4 {
        address = "${each.value.ip}/${each.value.network_cidr}"
        gateway = each.value.gw_ip
      }
    }
    dns {
      servers = compact([each.value.dns_server1, each.value.dns_server2])
    }
  }
  lifecycle {
    ignore_changes = [
      disk[0].file_id,
    ]
  }
}
