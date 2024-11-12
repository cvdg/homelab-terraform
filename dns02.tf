resource "libvirt_volume" "dns02" {
  provider       = libvirt.srv02
  count          = var.uninstall ? 0 : 1
  name           = "dns02.qcow2"
  pool           = libvirt_pool.srv02.name
  base_volume_id = libvirt_volume.srv02.id
  size           = var.vm_size
}

data "template_file" "dns02_user_data" {
  count    = var.uninstall ? 0 : 1
  template = file("${path.module}/cloud_init.yml")

  vars = {
    vm_hostname              = "dns02.${var.domainname}"
    cloudinit_username       = var.cloudinit_username
    cloudinit_password       = var.cloudinit_password
    cloudinit_ssh_public_key = var.cloudinit_ssh_public_key
  }
}

data "template_file" "dns02_network_config" {
  count    = var.uninstall ? 0 : 1
  template = file("${path.module}/network_config.yml")

  vars = {
    host_ip_address       = "192.168.2.129"
    gateway_ip_address    = var.cloudinit_gateway_ip_address
    nameserver_ip_address = var.cloudinit_nameserver_ip_address
  }
}

resource "libvirt_cloudinit_disk" "dns02" {
  provider = libvirt.srv02
  count    = var.uninstall ? 0 : 1

  name           = "dns02_cloudinit.iso"
  user_data      = data.template_file.dns02_user_data[count.index].rendered
  network_config = data.template_file.dns02_network_config[count.index].rendered
  pool           = libvirt_pool.srv02.name
}

resource "libvirt_domain" "dns02" {
  provider = libvirt.srv02
  count    = var.uninstall ? 0 : 1

  name       = "dns02"
  memory     = var.vm_memory
  vcpu       = var.vm_cpus
  running    = true
  autostart  = true
  qemu_agent = true
  cloudinit  = libvirt_cloudinit_disk.dns02[count.index].id

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    bridge         = "br0"
    hostname       = "dns02.${var.domainname}"
    addresses      = ["192.168.2.129"]
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.dns02[count.index].id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_port = "3"
    target_type = "virtio"
  }
}
