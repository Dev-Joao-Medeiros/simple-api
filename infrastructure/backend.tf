terraform {
  backend "s3" {
    bucket       = "kxc-simple-api-terraform-state-455958489873"
    key          = "simple-api/dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}