output "dns02_password" {
  value     = random_password.dns02_password.result
  sensitive = true
}

output "media01_password" {
  value     = random_password.media01_password.result
  sensitive = true
}

