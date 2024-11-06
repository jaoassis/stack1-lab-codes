terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.26.0"
    }
  }

  backend "s3" {
    bucket = "nome-do-bucket"
    key    = "state/stack1-lab/sa-east-1/lambda"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}