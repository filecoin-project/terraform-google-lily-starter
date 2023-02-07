data "google_compute_image" "deb" {
  family  = "debian-11"
  project = "debian-cloud"
}

resource "google_service_account" "lily" {
  account_id   = "lily"
  display_name = "Service account for managing compute instances containing Lily."
}

resource "google_compute_instance" "lily" {
  count = var.instances_per_project
  name  = "${var.instance_name}-${local.count.index}"

  # n2-custom-12-96000 equivalent to i3en.3x on aws, which was historically used for archiver
  # n2-highmem-4 is the rightsize suggestion from GCP for testnets
  machine_type = var.network == "mainnet" ? "n2-custom-12-96000" : "n2-highmem-4"
  zone         = var.zone

  # to make debugging easier
  metadata = {
    "serial-port-enable" = true
  }

  metadata_startup_script = templatefile("${path.module}/script.sh", { network = var.network, release = var.release })

  boot_disk {
    initialize_params {
      size  = var.network == "mainnet" ? 12 : 20 # in GB, 10 is not sufficient for lotus+build deps
      image = data.google_compute_image.deb.self_link
    }
  }

  network_interface {
    network = default

    access_config {}
  }

  service_account {
    email  = google_service_account.lily.email
    scopes = ["cloud-platform"]
  }

  labels = {
    created_by = "terraform"
    project    = "lily"
  }

  lifecycle {
    ignore_changes = [attached_disk, boot_disk]
  }
}

resource "google_compute_disk" "lily" {
  count = var.instances_per_project

  name  = "${var.instance_name}-ext-${count.index}"
  type  = "pd-ssd"
  zone  = var.zone
  image = data.google_compute_image.deb.self_link
  size  = var.for_mainnet ? 10000 : 2000 # in GB, i.e. 10TB, 2TB
  labels = {
    created_by = "terraform"
    project    = "lily"
  }

  lifecycle {
    ignore_changes = [image]
  }
}

resource "google_compute_attached_disk" "lily" {
  count    = var.instances_per_project
  disk     = google_compute_disk.lily[count.index].self_index
  instance = google_compute_instance.lily[count.index].self_index
}
