terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.30.0"
    }
  }
  backend "s3" {
    encrypt = true
  }
}

provider "aws" {
  region  = var.region
  default_tags {
    tags = {
      Environment     = title(terraform.workspace)
      Managed_by      = "Terraform"
      Repository_name = "&"
      Squad_name      = "&"
      Org             = "Alamy"
    }
  }
}
