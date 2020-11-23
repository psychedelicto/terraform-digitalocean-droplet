# Managed By : CloudDrove
# Description : This Script is used to create Droplet, Volume, Volume Attachment, and floating Ip.
# Copyright @ CloudDrove. All Right Reserved.


# Lookup image to get id
data "digitalocean_image" "official" {
  count = var.custom_image == true ? 0 : 1
  slug  = var.image_name
}

#Module      : Label
#Description : This terraform module is designed to generate consistent label names and
#              tags for resources. You can use terraform-labels to implement a strict
#              naming convention.
module "labels" {
  source      = "clouddrove/labels/digitalocean"
  version     = "0.13.0"
  name        = var.name
  application = var.application
  environment = var.environment
  label_order = var.label_order
}

#Module      : Droplet
#Description : Provides a DigitalOcean Droplet resource. This can be used to create, modify, and delete Droplets.
resource "digitalocean_droplet" "main" {
  count = var.droplet_enabled == true ? var.droplet_count : 0

  image              = var.droplet_slug
  name               = format("%s%s%s", module.labels.id, var.delimiter, (count.index))
  region             = coalesce(local.region[var.region], var.region)
  size               = coalesce(local.sizes[var.droplet_size], var.droplet_size)
  backups            = var.backups
  monitoring         = var.monitoring
  ipv6               = var.ipv6
  private_networking = var.private_networking
  ssh_keys           = var.ssh_keys
  resize_disk        = var.resize_disk
  user_data          = var.user_data
  vpc_uuid           = var.vpc_uuid

  tags = [
    module.labels.name,
    module.labels.application,
    module.labels.environment,
    module.labels.createdby,
    module.labels.managedby
  ]
}

#Module      : Volume
#Description : Provides a DigitalOcean Block Storage volume which can be attached to a Droplet in order to provide expanded storage.
resource "digitalocean_volume" "main" {
  count = var.droplet_enabled == true ? var.droplet_count : 0

  region                   = coalesce(local.region[var.region], var.region)
  name                     = format("%s%s%s%s%s", module.labels.id, var.delimiter, "volume", var.delimiter, (count.index))
  size                     = var.block_storage_size
  description              = "Block storage for ${element(digitalocean_droplet.main.*.name, count.index)}"
  initial_filesystem_label = var.block_storage_filesystem_label
  initial_filesystem_type  = var.block_storage_filesystem_type
  tags = [
    format("%s%s%s%s%s", module.labels.id, var.delimiter, "volume", var.delimiter, (count.index)),
    module.labels.application,
    module.labels.environment,
    module.labels.createdby,
    module.labels.managedby
  ]

}

#Module      : Volume Attachment
#Description : Manages attaching a Volume to a Droplet.
resource "digitalocean_volume_attachment" "main" {
  count = var.droplet_enabled == true ? var.droplet_count : 0

  droplet_id = element(digitalocean_droplet.main.*.id, count.index)
  volume_id  = element(digitalocean_volume.main.*.id, count.index)
}

#Module      : Floating Ip
#Description : Provides a DigitalOcean Floating IP to represent a publicly-accessible static IP addresses that can be mapped to one of your Droplets.
resource "digitalocean_floating_ip" "main" {
  count  = var.floating_ip == true && var.droplet_enabled == true ? var.droplet_count : 0
  region = coalesce(local.region[var.region], var.region)
}

#Module      : Floating Ip Assignment
#Description : Provides a DigitalOcean Floating IP to represent a publicly-accessible static IP addresses that can be mapped to one of your Droplets.
resource "digitalocean_floating_ip_assignment" "main" {
  count = var.floating_ip == true && var.droplet_enabled == true ? var.droplet_count : 0

  ip_address = element(digitalocean_floating_ip.main.*.id, count.index)
  droplet_id = element(digitalocean_droplet.main.*.id, count.index)
  depends_on = [digitalocean_droplet.main]
}
