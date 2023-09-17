terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "state-bucket"
    key    = "eks-state"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}

