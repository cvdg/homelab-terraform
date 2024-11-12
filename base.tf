resource "libvirt_volume" "srv01" {
  provider = libvirt.srv01
  name     = "base.img"
  pool     = libvirt_pool.srv01.name
  source   = var.base_img_url
  format   = "qcow2"
}

resource "libvirt_volume" "srv02" {
  provider = libvirt.srv02
  name     = "base.img"
  pool     = libvirt_pool.srv02.name
  source   = var.base_img_url
  format   = "qcow2"
}
