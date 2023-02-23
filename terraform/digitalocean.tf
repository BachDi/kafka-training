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

variable "ssh_private_key" {
  description = "Private key to connect to instance through SSH"
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

  # connection {
  #   type        = "ssh"
  #   user        = "root"
  #   private_key = var.ssh_private_key
  #   host        = self.ipv4_address
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "mkdir -p ~/.ssh",
  #     "echo '${var.ssh_public_key}' >> ~/.ssh/authorized_keys",
  #     "chmod 700 ~/.ssh",
  #     "chmod 600 ~/.ssh/authorized_keys",
  #     "service ssh restart",
  #   ]
  # } 
}

resource "digitalocean_firewall" "terraform-training" {
  name = "terraform-training"

  droplet_ids = [digitalocean_droplet.terraform-training.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "8080"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  inbound_rule {
    protocol         = "tcp"
    port_range       = "9092"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  inbound_rule {
    protocol         = "tcp"
    port_range       = "19092"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  inbound_rule {
    protocol         = "tcp"
    port_range       = "29092"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # inbound_rule {
  #   protocol         = "tcp"
  #   port_range       = "443"
  #   source_addresses = ["0.0.0.0/0", "::/0"]
  # }
}
