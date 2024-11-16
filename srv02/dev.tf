resource "libvirt_volume" "dev" {
  count          = var.dev_enabled ? var.dev_count : 0
  name           = format("dev%02g.qcow2", 1 + count.index)
  pool           = libvirt_pool.pool.name
  base_volume_id = libvirt_volume.base.id
  size           = var.vm_size_16GB * 2
}

data "template_file" "dev_user_data" {
  count    = var.dev_enabled ? var.dev_count : 0
  template = file("${path.module}/cloud_init.yml")

  vars = {
    hostname       = format("dev%02g.${var.domainname}", 1 + count.index)
    username       = var.cloudinit_username
    password       = random_password.password.result
    ssh_public_key = var.cloudinit_ssh_public_key
    swapsize       = 4
  }
}

data "template_file" "dev_network_config" {
  count    = var.dev_enabled ? var.dev_count : 0
  template = file("${path.module}/network_config.yml")

  vars = {
    host_ip_address = format("192.168.2.%g", 133 + count.index)
  }
}

resource "libvirt_cloudinit_disk" "dev" {
  count = var.dev_enabled ? var.dev_count : 0

  name           = format("dev%02g_cloudinit.iso", 1 + count.index)
  user_data      = data.template_file.dev_user_data[count.index].rendered
  network_config = data.template_file.dev_network_config[count.index].rendered
  pool           = libvirt_pool.pool.name
}

resource "libvirt_domain" "dev" {
  count = var.dev_enabled ? var.dev_count : 0

  name       = format("dev%02g", 1 + count.index)
  memory     = var.vm_memory_1GB * 2
  vcpu       = var.vm_cpus
  running    = true
  autostart  = true
  qemu_agent = true
  cloudinit  = libvirt_cloudinit_disk.dev[count.index].id

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    bridge         = "br0"
    hostname       = format("dev%02g.${var.domainname}", 1 + count.index)
    addresses      = [format("192.168.2.%g", 133 + count.index)]
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.dev[count.index].id
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

