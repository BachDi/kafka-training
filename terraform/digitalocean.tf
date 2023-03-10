terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.26.0"
    }
  }
}

variable "do_token" {
  default = ""
}

variable "ssh_public_key" {
  description = "Public key to connect to instance through SSH"
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_ssh_key" "default" {
  name       = "DO Default SSH Key"
  public_key = var.ssh_public_key
}

resource "digitalocean_droplet" "terraform-training" {
  image  = "ubuntu-20-04-x64"
  name   = "terraform-training"
  region = "sgp1"
  size   = "s-1vcpu-2gb"
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]
  user_data = file("kafka.sh")
}


output "droplet_output" {
  value = digitalocean_droplet.terraform-training.ipv4_address
}
