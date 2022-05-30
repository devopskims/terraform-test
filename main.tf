terraform {
  backend "s3" {                                                          
    bucket  = "backup-s3-terraform"                                       
    key     = "terraform/own-your-path/terraform.databackup-s3-terraform" 
    region  = "ap-northeast-2"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "ap-northeast-2"
}



