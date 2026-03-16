terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

locals {
  all_machine_configuration = merge(
    var.controller_machine_configuration,
    var.worker_machine_configuration,
  )

  rule_1_2_1_per_vm = {
    for vm_name, vm in var.vms :
    vm_name => (
      anytrue([
        for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
        anytrue([
          for key in try(yamldecode(patch).machine.systemDiskEncryption.state.keys, []) :
          try(key.tpm, null) != null || try(key.kms, null) != null
        ])
      ]) && anytrue([
        for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
        anytrue([
          for key in try(yamldecode(patch).machine.systemDiskEncryption.ephemeral.keys, []) :
          try(key.tpm, null) != null || try(key.kms, null) != null
        ])
      ])
      ? "pass"
      : "fail"
    )
  }

  rule_1_2_1_result = alltrue([
    for vm_name, result in local.rule_1_2_1_per_vm : result == "pass"
  ]) ? "pass" : "fail"

  rule_1_3_per_vm = {
    for vm_name, vm in var.vms :
    vm_name => try(
      element(compact([
        for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
        try(yamldecode(patch).machine.install.image, null)
      ]), 0),
      null
    )
  }

  rule_1_3_result = try(
    element(compact([
      for vm_name, result in local.rule_1_3_per_vm : result
    ]), 0),
    ""
  )

  rule_2_1_per_vm = {
    for vm_name, vm in var.vms :
    vm_name => (
      anytrue([
        for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
        length(try(yamldecode(patch).machine.time.servers, [])) > 0
      ])
      ? "pass"
      : "fail"
    )
  }

  rule_2_1_result = alltrue([
    for vm_name, result in local.rule_2_1_per_vm : result == "pass"
  ]) ? "pass" : "fail"

  rule_3_1_per_vm = {
    for vm_name, vm in var.vms :
    vm_name => (
      anytrue([
        for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
        try(yamldecode(patch).cluster.allowSchedulingOnControlPlanes == true, false)
      ])
      ? "fail"
      : "pass"
    )
  }
  rule_3_1_result = alltrue([
    for vm_name, result in local.rule_3_1_per_vm : result == "pass"
  ]) ? "pass" : "fail"

  rule_4_1_per_vm = {
    for vm_name, vm in var.vms :
    vm_name => (
      anytrue([
        for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
        try(yamldecode(patch).machine.features.rbac == true, false)
      ])
      ? "pass"
      : "fail"
    )
  }

rule_4_1_result = alltrue([
    for vm_name, result in local.rule_4_1_per_vm : result == "pass"
]) ? "pass" : "fail"

rule_5_1_1_per_vm = {
  for vm_name, vm in var.vms :
  vm_name => (
    anytrue([
      for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
      try(
        tostring(yamldecode(patch).machine.sysctls["net.ipv4.conf.all.send_redirects"]) == "0",
        false
      )
    ])
    &&
    anytrue([
      for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
      try(
        tostring(yamldecode(patch).machine.sysctls["net.ipv4.conf.default.send_redirects"]) == "0",
        false
      )
    ])
    ? "pass"
    : "fail"
  )
}

rule_5_1_1_result = alltrue([
  for vm_name, result in local.rule_5_1_1_per_vm : result == "pass"
]) ? "pass" : "fail"

rule_5_2_1_per_vm = {
  for vm_name, vm in var.vms :
  vm_name => (
    anytrue([
      for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
      try(
        tostring(yamldecode(patch).machine.sysctls["net.ipv4.conf.all.accept_source_route"]) == "0",
        false
      )
    ])
    &&
    anytrue([
      for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
      try(
        tostring(yamldecode(patch).machine.sysctls["net.ipv4.conf.default.accept_source_route"]) == "0",
        false
      )
    ])
    ? "pass"
    : "fail"
  )
}

rule_5_2_1_result = alltrue([
  for vm_name, result in local.rule_5_2_1_per_vm : result == "pass"
]) ? "pass" : "fail"

rule_5_2_2_per_vm = {
  for vm_name, vm in var.vms :
  vm_name => (
    anytrue([
      for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
      try(
        tostring(yamldecode(patch).machine.sysctls["net.ipv4.conf.all.accept_redirects"]) == "0",
        false
      )
    ])
    &&
    anytrue([
      for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
      try(
        tostring(yamldecode(patch).machine.sysctls["net.ipv4.conf.default.accept_redirects"]) == "0",
        false
      )
    ])
    ? "pass"
    : "fail"
  )
}

rule_5_2_2_result = alltrue([
  for vm_name, result in local.rule_5_2_2_per_vm : result == "pass"
]) ? "pass" : "fail"

rule_5_2_3_per_vm = {
  for vm_name, vm in var.vms :
  vm_name => (
    anytrue([
      for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
      try(
        tostring(yamldecode(patch).machine.sysctls["net.ipv4.conf.all.secure_redirects"]) == "0",
        false
      )
    ])
    &&
    anytrue([
      for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
      try(
        tostring(yamldecode(patch).machine.sysctls["net.ipv4.conf.default.secure_redirects"]) == "0",
        false
      )
    ])
    ? "pass"
    : "fail"
  )
}

rule_5_2_3_result = alltrue([
  for vm_name, result in local.rule_5_2_3_per_vm : result == "pass"
]) ? "pass" : "fail"

rule_5_2_4_per_vm = {
  for vm_name, vm in var.vms :
  vm_name => (
    anytrue([
      for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
      try(
        tostring(yamldecode(patch).machine.sysctls["net.ipv4.conf.all.log_martians"]) == "1",
        false
      )
    ])
    &&
    anytrue([
      for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
      try(
        tostring(yamldecode(patch).machine.sysctls["net.ipv4.conf.default.log_martians"]) == "1",
        false
      )
    ])
    ? "pass"
    : "fail"
  )
}

rule_5_2_4_result = alltrue([
  for vm_name, result in local.rule_5_2_4_per_vm : result == "pass"
]) ? "pass" : "fail"

rule_5_2_5_per_vm = {
  for vm_name, vm in var.vms :
  vm_name => (
    anytrue([
      for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
      try(
        tostring(yamldecode(patch).machine.sysctls["net.ipv4.icmp_echo_ignore_broadcasts"]) == "1",
        false
      )
    ])
    ? "pass"
    : "fail"
  )
}

rule_5_2_5_result = alltrue([
  for vm_name, result in local.rule_5_2_5_per_vm : result == "pass"
]) ? "pass" : "fail"

rule_5_2_6_per_vm = {
  for vm_name, vm in var.vms :
  vm_name => (
    anytrue([
      for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
      try(
        tostring(yamldecode(patch).machine.sysctls["net.ipv4.icmp_ignore_bogus_error_responses"]) == "1",
        false
      )
    ])
    ? "pass"
    : "fail"
  )
}

rule_5_2_6_result = alltrue([
  for vm_name, result in local.rule_5_2_6_per_vm : result == "pass"
]) ? "pass" : "fail"

rule_5_2_7_per_vm = {
  for vm_name, vm in var.vms :
  vm_name => (
    anytrue([
      for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
      try(
        tostring(yamldecode(patch).machine.sysctls["net.ipv4.tcp_syncookies"]) == "1",
        false
      )
    ])
    ? "pass"
    : "fail"
  )
}

rule_5_2_7_result = alltrue([
  for vm_name, result in local.rule_5_2_7_per_vm : result == "pass"
]) ? "pass" : "fail"

rule_5_2_8_per_vm = {
  for vm_name, vm in var.vms :
  vm_name => (
    anytrue([
      for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
      try(
        tostring(yamldecode(patch).machine.sysctls["net.ipv4.conf.all.rp_filter"]) == "1",
        false
      )
    ])
    &&
    anytrue([
      for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
      try(
        tostring(yamldecode(patch).machine.sysctls["net.ipv4.conf.default.rp_filter"]) == "1",
        false
      )
    ])
    ? "pass"
    : "fail"
  )
}

rule_5_2_8_result = alltrue([
  for vm_name, result in local.rule_5_2_8_per_vm : result == "pass"
]) ? "pass" : "fail"

rule_6_1_1_per_vm = {
  for vm_name, vm in var.vms :
  vm_name => (
    anytrue([
      for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
      anytrue([
        for arg in try(yamldecode(patch).machine.install.extraKernelArgs, []) :
        startswith(tostring(arg), "talos.logging.kernel=")
      ])
    ])
    ? "pass"
    : "fail"
  )
}

rule_6_1_1_result = alltrue([
  for vm_name, result in local.rule_6_1_1_per_vm : result == "pass"
]) ? "pass" : "fail"

rule_6_2_1_per_vm = {
  for vm_name, vm in var.vms :
  vm_name => (
    anytrue([
      for patch in try(local.all_machine_configuration[vm_name].config_patches, []) :
      length(try(yamldecode(patch).machine.logging.destinations, [])) > 0
    ])
    ? "pass"
    : "fail"
  )
}

rule_6_2_1_result = alltrue([
  for vm_name, result in local.rule_6_2_1_per_vm : result == "pass"
]) ? "pass" : "fail"

}
resource "kubernetes_config_map_v1" "talos-node-audit" {
  metadata {
    name      = "talos-node-audit"
    namespace = "flux-system"
  }
  data = {
    RULE_1_2_1_RESULT = local.rule_1_2_1_result
    RULE_1_3_RESULT = local.rule_1_3_result
    RULE_2_1_RESULT = local.rule_2_1_result
    RULE_3_1_RESULT = local.rule_3_1_result
    RULE_4_1_RESULT   = local.rule_4_1_result
    RULE_5_1_1_RESULT = local.rule_5_1_1_result
    RULE_5_2_1_RESULT = local.rule_5_2_1_result
    RULE_5_2_2_RESULT = local.rule_5_2_2_result
    RULE_5_2_3_RESULT = local.rule_5_2_3_result
    RULE_5_2_4_RESULT = local.rule_5_2_4_result
    RULE_5_2_5_RESULT = local.rule_5_2_5_result
    RULE_5_2_6_RESULT = local.rule_5_2_6_result
    RULE_5_2_7_RESULT = local.rule_5_2_7_result
    RULE_5_2_8_RESULT = local.rule_5_2_8_result
    RULE_6_1_1_RESULT = local.rule_6_1_1_result
    RULE_6_2_1_RESULT = local.rule_6_2_1_result
  }
}
