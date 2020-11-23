output "id" {
  value       = digitalocean_droplet.main.*.id
  description = "The ID of the Droplet."
}

output "urn" {
  value       = digitalocean_droplet.main.*.urn
  description = "The uniform resource name of the Droplet."
}

output "name" {
  value       = digitalocean_droplet.main.*.name
  description = "The name of the Droplet."
}

output "ipv4_address_private" {
  value       = digitalocean_droplet.main.*.ipv4_address_private
  description = "The name of the Droplet."
}
