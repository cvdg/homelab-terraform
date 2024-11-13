output "dns03_password" {
  value     = random_password.dns03_password.result
  sensitive = true
}

