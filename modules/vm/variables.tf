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

  validation {
    condition     = alltrue([for k, v in var.instances : can(regex("^[a-z]+-[a-z]+[0-9]+-[a-z]$", v.zone))])
   error_message = "Each zone must look like us-central1-a."
  }
}