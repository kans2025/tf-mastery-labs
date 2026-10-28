terraform {
  backend "gcs" {
    bucket = "kg102026-tfstate-lab"
    prefix = "stage/vm"
  }
}

module "vm" {
  source      = "../../modules/vm"
  project_id  = var.project_id
  environment = "stage"
  instances = {
    "web-1" = {
      machine_type = "e2-micro"
      zone         = "us-central1-a"
    }
  }
}
