resource "google_compute_instance" "web" {
  for_each     = var.instances
  name         = "${var.environment}-${each.key}"
  machine_type = each.value.machine_type
  zone         = each.value.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
  }
}

resource "google_compute_firewall" "allow_ssh" {
  name          = "${var.environment}-allow-ssh"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}