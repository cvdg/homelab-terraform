
resource "libvirt_volume" "base" {
  name   = "base.img"
  pool   = libvirt_pool.pool.name
  source = var.base_img_url
  format = "qcow2"
}
