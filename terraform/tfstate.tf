terraform {
  backend "s3" {
    bucket = "cxcloud-demo-terraform-state"
    key    = "terraform-state"
    region = "eu-west-1"
  }
}
