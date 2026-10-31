mock_provider "google" {}

variables {
  project_id  = "test-project"
  environment = "dev"
  instances = {
    "web-1" = {
      machine_type = "e2-micro"
      zone         = "us-central1-a"
    }
  }
}

run "valid_environment" {
  command = plan

  assert {
    condition     = var.environment != ""
    error_message = "environment must be set"
  }
}