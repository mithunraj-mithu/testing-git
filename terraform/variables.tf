variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "service" {
  type    = string
  default = "terraform-template"

  validation {
    condition     = var.service != "terraform-template"
    error_message = "Update the 'service' variable. Do not use the template default."
  }
}

