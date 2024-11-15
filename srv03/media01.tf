resource "libvirt_volume" "media01" {
  count          = var.media01_enabled ? 1 : 0
  name           = "media01.qcow2"
  pool           = libvirt_pool.pool.name
  base_volume_id = libvirt_volume.base.id
  size           = var.vm_size
}

resource "random_password" "media01_password" {
  length  = 12
  special = false
}

data "template_file" "media01_user_data" {
  count    = var.media01_enabled ? 1 : 0
  template = file("${path.module}/cloud_init.yml")

  vars = {
    hostname       = "media01.${var.domainname}"
    username       = var.cloudinit_username
    password       = random_password.media01_password.result
    ssh_public_key = var.cloudinit_ssh_public_key
    swapsize       = 8
  }
}

data "template_file" "media01_network_config" {
  count    = var.media01_enabled ? 1 : 0
  template = file("${path.module}/network_config.yml")

  vars = {
    host_ip_address = "192.168.2.131"
  }
}

resource "libvirt_cloudinit_disk" "media01" {
  count = var.media01_enabled ? 1 : 0

  name           = "media01_cloudinit.iso"
  user_data      = data.template_file.media01_user_data[count.index].rendered
  network_config = data.template_file.media01_network_config[count.index].rendered
  pool           = libvirt_pool.pool.name
}

resource "libvirt_domain" "media01" {
  count = var.media01_enabled ? 1 : 0

  name       = "media01"
  memory     = 4 * 1024
  vcpu       = 4
  running    = true
  autostart  = true
  qemu_agent = true
  cloudinit  = libvirt_cloudinit_disk.media01[count.index].id

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    bridge         = "br0"
    hostname       = "media01.${var.domainname}"
    addresses      = ["192.168.2.131"]
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.media01[count.index].id
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

