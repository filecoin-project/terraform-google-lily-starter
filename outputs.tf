output "service_account" {
  description = "Service account for managing compute instances containing Lily."
  value       = google_service_account.lily
}

output "instance_ids" {
  description = "Compute instance IDs."
  value       = [google_compute_instance.lily.*.instance_id]
}

output "instance_ips" {
  description = "External IP addresses for the compute instances."
  value       = [google_compute_instance.lily.*.network_interface.0.access_config.0.nat_ip]
}
