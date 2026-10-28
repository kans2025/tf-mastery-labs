terraform {
  backend "gcs" {
    bucket = "kg102026-tfstate-lab"
    prefix = "prod/vm"
  }
}

module "vm" {
  source      = "../../modules/vm"
  project_id  = var.project_id
  environment = "prod"
  instances = {
    "web-1" = {
      machine_type = "e2-micro"
      zone         = "us-central1-a"
    }
  }
}
