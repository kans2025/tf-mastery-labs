mock_provider "google" {}

variables {
  project_id  = "test-project"
  environment = "dev"
}

run "rejects_invalid_zone" {
  command = plan

  variables {
    instances = {
      "web-1" = {
        machine_type = "e2-micro"
        zone         = "not-a-real-zone"
      }
    }
  }

  expect_failures = [var.instances]
}