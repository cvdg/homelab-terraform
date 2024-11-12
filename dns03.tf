resource "libvirt_volume" "dns03" {
  provider       = libvirt.srv01
  count          = var.uninstall ? 0 : 1
  name           = "dns03.qcow2"
  pool           = libvirt_pool.srv01.name
  base_volume_id = libvirt_volume.srv01.id
  size           = var.vm_size
}

data "template_file" "dns03_user_data" {
  count    = var.uninstall ? 0 : 1
  template = file("${path.module}/cloud_init.yml")

  vars = {
    vm_hostname              = "dns03.${var.domainname}"
    cloudinit_username       = var.cloudinit_username
    cloudinit_password       = var.cloudinit_password
    cloudinit_ssh_public_key = var.cloudinit_ssh_public_key
  }
}

data "template_file" "dns03_network_config" {
  count    = var.uninstall ? 0 : 1
  template = file("${path.module}/network_config.yml")

  vars = {
    host_ip_address       = "192.168.2.130"
    gateway_ip_address    = var.cloudinit_gateway_ip_address
    nameserver_ip_address = var.cloudinit_nameserver_ip_address
  }
}

resource "libvirt_cloudinit_disk" "dns03" {
  provider = libvirt.srv01
  count    = var.uninstall ? 0 : 1

  name           = "dns03_cloudinit.iso"
  user_data      = data.template_file.dns03_user_data[count.index].rendered
  network_config = data.template_file.dns03_network_config[count.index].rendered
  pool           = libvirt_pool.srv02.name
}

resource "libvirt_domain" "dns03" {
  provider = libvirt.srv01
  count    = var.uninstall ? 0 : 1

  name       = "dns03"
  memory     = var.vm_memory
  vcpu       = var.vm_cpus
  running    = true
  autostart  = true
  qemu_agent = true
  cloudinit  = libvirt_cloudinit_disk.dns03[count.index].id

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    bridge         = "br0"
    hostname       = "dns03.${var.domainname}"
    addresses      = ["192.168.2.130"]
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.dns03[count.index].id
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
