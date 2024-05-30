terraform {
  backend "s3" {
    bucket = "shiprocket-terraform-state"
    key    = "staging/karpenter/terraform.tfstate"
    region = "ap-south-1"
  }
}
