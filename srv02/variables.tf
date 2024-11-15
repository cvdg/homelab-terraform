variable "cloudinit_username" {
  description = "Cloud-init: Username"
  type        = string
  default     = "ansible"
}

variable "cloudinit_ssh_public_key" {
  description = "Cloud-init: ssh authorized keys"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIARZzMKZ4lIEdk5Qd7SEl9FuMNOv1t1LExbtHg6HeBKF ansible@griend.dev"
}

variable "cloudinit_gateway_ip_address" {
  description = "IP address of the gateway"
  type        = string
  default     = "192.168.2.254"
}

variable "base_img_url" {
  description = "URL to debian cloud img qcow2"
  type        = string
  default     = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
}

variable "libvirt_pool_name" {
  description = "libvirt pool name"
  type        = string
  default     = "homelab"
}

variable "libvirt_pool_path" {
  description = "Libvirt pool dir path"
  type        = string
  default     = "/srv/homelab"
}

variable "vm_size_16GB" {
  description = "Size of the VM root partition (16 GiB)"
  type        = number
  default     = 16 * 1024 * 1024 * 1024
}

variable "vm_memory_1GB" {
  description = "Memory of the VM (2 GiB)"
  type        = number
  default     = 1 * 1024
}

variable "vm_cpus" {
  description = "CPUs of the VM (2)"
  type        = number
  default     = 2
}

variable "domainname" {
  type    = string
  default = "griend.dev"
}

variable "dns03_enabled" {
  type    = bool
  default = true
}

variable "admin01_enabled" {
  type    = bool
  default = true
}

