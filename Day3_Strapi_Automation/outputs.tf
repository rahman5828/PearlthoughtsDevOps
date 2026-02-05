output "instance_public_ip" {
  description = "The public IP of the Strapi server (captured from module)"
  value       = module.strapi_app.public_ip
}