package terraform.policy

# input = tfplan.json (terraform show -json); resource_changes = every resource the plan touches
deny contains msg if {
  some resource in input.resource_changes
  resource.type == "google_storage_bucket_iam_binding"
  some member in resource.change.after.members
  member == "allUsers"
  msg := "public bucket access is not allowed"
}

deny contains msg if {
  some resource in input.resource_changes
  resource.type == "google_compute_firewall"   # matches by type, so module.vm.* nesting does not matter
  some range in resource.change.after.source_ranges
  range == "0.0.0.0/0"
  some allow in resource.change.after.allow
  some port in allow.ports
  port == "22"
  msg := "SSH open to the internet is not allowed"
}