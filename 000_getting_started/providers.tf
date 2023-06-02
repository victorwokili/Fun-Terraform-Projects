

provider "aws" {
  # Configuration options
  region  = "us-west-1"
  #profile = "default"
}

provider "aws" {
  # Additional provider for us-west-1 california
  region  = "us-west-1"
  #profile = "default"
  alias = "cali"
}