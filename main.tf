resource "null_resource" "dependency_getter" {
  provisioner "local-exec" {
    command = "echo ${length(var.dependencies)}"
  }
}

resource "random_id" "bucketAid" {
  byte_length = 4
  prefix      = "busketa-"
}

resource "google_storage_bucket" "bucketA" {
  name     = random_id.bucketAid.hex
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network       = "default"
    access_config {
    }
  }
}

resource "null_resource" "dependency_setter" {
  depends_on = [
    "google_storage_bucket.bucketA",
  ]
}

variable "dependencies" {
  type    = "list"
  default = []
}

output "depended_on" {
  value = "${null_resource.dependency_setter.id}"
}
