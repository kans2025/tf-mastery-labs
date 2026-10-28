output "instance_names" {
  value = [for k, v in google_compute_instance.web : v.name]
}