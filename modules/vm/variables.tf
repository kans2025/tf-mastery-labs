variable "project_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "instances" {
  type = map(object({
    machine_type = string
    zone         = string
  }))
}