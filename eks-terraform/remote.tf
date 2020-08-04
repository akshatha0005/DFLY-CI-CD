# Defining backend to store the terraform state files to push and pull the state files to
# S3 bucket and during the apply, state locks are generated in DynamoDB tables to avoid
# collision during applies 

terraform {
  backend "s3" {
    acl            = "private"
    bucket         = "dfly-assesment-tf"
    key            = "eks-terraform/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-state-lock"
  }
}
