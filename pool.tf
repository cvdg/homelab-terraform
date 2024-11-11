resource "libvirt_pool" "pool" {
  name = var.libvirt_pool_name
  type = "dir"

  target {
    path = var.libvirt_pool_path
  }
}
