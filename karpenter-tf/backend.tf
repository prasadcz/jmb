terraform {
  backend "s3" {
    bucket = "jmb-terraform-alpha"
    key    = "terraform/non-prod/karpenter/terraform.tfstate"
    region = "ap-southeast-1"
    profile = "nonprod"
  }
}