terraform {
  backend "s3" {
    acl            = "private"
    bucket         = "dfly-assesment-tf"
    key            = "eks-terraform/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-state-lock"
  }
}
