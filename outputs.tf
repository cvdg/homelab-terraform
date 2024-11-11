output "dns_ip_address" {
  value = {
    for vm in libvirt_domain.dns :
    vm.name => vm.network_interface.0.addresses.0
  }
}

output "gitlab_ip_address" {
  value = {
    for vm in libvirt_domain.gitlab :
    vm.name => vm.network_interface.0.addresses.0
  }
}
