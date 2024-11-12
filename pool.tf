resource "libvirt_pool" "srv01" {
  provider = libvirt.srv01
  name     = var.libvirt_pool_name
  type     = "dir"

  target {
    path = var.libvirt_pool_path
  }
}

resource "libvirt_pool" "srv02" {
  provider = libvirt.srv02
  name     = var.libvirt_pool_name
  type     = "dir"

  target {
    path = var.libvirt_pool_path
  }
}
