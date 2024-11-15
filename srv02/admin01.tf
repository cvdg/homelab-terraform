resource "libvirt_volume" "admin01" {
  count          = var.admin01_enabled ? 1 : 0
  name           = "admin01.qcow2"
  pool           = libvirt_pool.pool.name
  base_volume_id = libvirt_volume.base.id
  size           = var.vm_size_16GB * 2
}

data "template_file" "admin01_user_data" {
  count    = var.admin01_enabled ? 1 : 0
  template = file("${path.module}/cloud_init.yml")

  vars = {
    hostname       = "admin01.${var.domainname}"
    username       = var.cloudinit_username
    password       = random_password.password.result
    ssh_public_key = var.cloudinit_ssh_public_key
    swapsize       = 4
  }
}

data "template_file" "admin01_network_config" {
  count    = var.admin01_enabled ? 1 : 0
  template = file("${path.module}/network_config.yml")

  vars = {
    host_ip_address = "192.168.2.132"
  }
}

resource "libvirt_cloudinit_disk" "admin01" {
  count = var.admin01_enabled ? 1 : 0

  name           = "admin01_cloudinit.iso"
  user_data      = data.template_file.admin01_user_data[count.index].rendered
  network_config = data.template_file.admin01_network_config[count.index].rendered
  pool           = libvirt_pool.pool.name
}

resource "libvirt_domain" "admin01" {
  count = var.admin01_enabled ? 1 : 0

  name       = "admin01"
  memory     = var.vm_memory_1GB * 4
  vcpu       = 4
  running    = true
  autostart  = true
  qemu_agent = true
  cloudinit  = libvirt_cloudinit_disk.admin01[count.index].id

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    bridge         = "br0"
    hostname       = "admin01.${var.domainname}"
    addresses      = ["192.168.2.132"]
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.admin01[count.index].id
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

