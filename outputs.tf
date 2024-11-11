output "dns_ip_address" {
  value = {
    for vm in libvirt_domain.dns :
    vm.name => vm.network_interface.0.addresses.0
  }
}
