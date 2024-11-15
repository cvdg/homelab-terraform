resource "libvirt_volume" "dns02" {
  count          = var.dns02_enabled ? 1 : 0
  name           = "dns02.qcow2"
  pool           = libvirt_pool.pool.name
  base_volume_id = libvirt_volume.base.id
  size           = var.vm_size
}

resource "random_password" "dns02_password" {
  length  = 12
  special = false
}

data "template_file" "dns02_user_data" {
  count    = var.dns02_enabled ? 1 : 0
  template = file("${path.module}/cloud_init.yml")

  vars = {
    hostname       = "dns02.${var.domainname}"
    username       = var.cloudinit_username
    password       = random_password.dns02_password.result
    ssh_public_key = var.cloudinit_ssh_public_key
    swapsize       = 2
  }
}

data "template_file" "dns02_network_config" {
  count    = var.dns02_enabled ? 1 : 0
  template = file("${path.module}/network_config.yml")

  vars = {
    host_ip_address = "192.168.2.129"
  }
}

resource "libvirt_cloudinit_disk" "dns02" {
  count = var.dns02_enabled ? 1 : 0

  name           = "dns02_cloudinit.iso"
  user_data      = data.template_file.dns02_user_data[count.index].rendered
  network_config = data.template_file.dns02_network_config[count.index].rendered
  pool           = libvirt_pool.pool.name
}

resource "libvirt_domain" "dns02" {
  count = var.dns02_enabled ? 1 : 0

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
    target_port = "1"
    target_type = "virtio"
  }
}
