mock_provider "google" {}

variables {
  project_id  = "test-project"
  environment = "dev"
}

run "creates_expected_instances" {
  command = plan

  variables {
    instances = {
      "web-1" = {
        machine_type = "e2-micro"
        zone         = "us-central1-a"
      }
    }
  }

  assert {
    condition     = length(google_compute_instance.web) == 1
    error_message = "expected exactly one instance"
  }
}