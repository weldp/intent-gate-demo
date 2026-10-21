terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
  }
}

# Set to true only for the offline demo (no AWS credentials).
# In CI, each alias assumes a read-only plan role in its own account.
variable "offline_demo" {
  type    = bool
  default = false
}

variable "prod_account_id" {
  type    = string
  default = "111111111111"
}

variable "test_account_id" {
  type    = string
  default = "222222222222"
}

provider "aws" {
  alias  = "prod"
  region = "us-east-1"

  skip_credentials_validation = var.offline_demo
  skip_requesting_account_id  = var.offline_demo
  skip_metadata_api_check     = var.offline_demo
}

provider "aws" {
  alias  = "test"
  region = "us-east-1"

  skip_credentials_validation = var.offline_demo
  skip_requesting_account_id  = var.offline_demo
  skip_metadata_api_check     = var.offline_demo
}
