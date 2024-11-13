output "dns02_password" {
  value     = random_password.dns02_password.result
  sensitive = true
}

