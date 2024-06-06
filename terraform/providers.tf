terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.52.0"
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
      Service        = "template"
      TeamName       = "template"
      RepositoryName = "template"
      CreatedBy      = "Terraform"
      Environment    = title(terraform.workspace)
      Org            = "Alamy"
    }
  }
}
