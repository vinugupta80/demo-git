provider "google" {
  project = "my-first-project-ngu"
  #credentials = "C:/Users/zvrk0752/Downloads/cred.json"
  #credentials = var.credentials
  region = "asia-south2"
  zone   = "asia-south2-a"

}

resource "google_compute_address" "external" {
  name         = "ext-ip-vm1-vm-terraform"
  address_type = "EXTERNAL"
  region       = "asia-south2"
}

resource "google_compute_instance" "vm_terraform" {
  project      = "my-first-project-ngu"
  name         = "vm1-terraform"
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  network_interface {
    network    = "asia-delhi-vpc1"
    subnetwork = "asia-south2-subnet"
    access_config {
      nat_ip = google_compute_address.external.address
    }
  }
  service_account {
    email  = "terraform-sa@my-first-project-ngu.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  provisioner "local-exec" {
    command = "echo the server IP address is ${self.name} >> private_ip.txt"
  }
}


output "vm1-terraform-details" {
  value = [
    google_compute_instance.vm_terraform.machine_type,
    google_compute_instance.vm_terraform.name,
    google_compute_instance.vm_terraform.zone,
    #google_compute_instance.vm_terraform.network_interface.id,
    google_compute_instance.vm_terraform.network_interface[0],
    #google_compute_instance.vm_terraform.subnetwork
  ]

}
output "ext-ip-details" {
  value = google_compute_address.external.address
}


/*
Global address is for Load balancer
resource "google_compute_global_address" "ext_ip" {
  name = "ext-ip-vm1-terraform"
  ip_version = "IPV4"
  region = "asia-south2"
}

output "ext-ip-details" {
  value = google_compute_global_address.ext_ip.address

}
*/
