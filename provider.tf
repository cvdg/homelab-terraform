terraform {
  required_version = ">= 1.9.8"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.8.1"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.2"
    }

    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }
  }
}

provider "libvirt" {
  alias = "srv01"
  uri   = "qemu+ssh://cees@srv01.griend.dev/system"
}

provider "libvirt" {
  alias = "srv02"
  uri   = "qemu+ssh://cees@srv02.griend.dev/system"
}
