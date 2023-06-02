terraform {
  cloud {
    organization = "wokili"
    workspaces {
      name = "getting-started"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0.1"
    }
  }
}

locals {
 project_name = "Wokili"
}