provider "aws" {
  region                  = "ap-southeast-1"
  profile                 = "nonprod"
}

provider "aws" {
  region                  = "ap-southeast-1"
  profile                 = "jumbotail"
  alias                   = "jumbotail"
}