variable "cidr_block"  {
type    = string
default = "10.0.0.0/16"
}

variable "name"{
  type = string
  default= "eks-vpc"
}

variable "region_zones" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "desired_size" {
  type = number
  default = 4
}

variable "max_worker_nodes"{
  type = number
  default = 4
}

variable "min_worker_nodes" {
  type = number
  default = 1
}

variable "eks_cluster_name"{
  type = string
  default= "dfly-eks-cluster"
}

variable "instance_type" {
  type = string
  default= "t3.micro"
}

variable "ami_id"{
  type = string
  default= "ami-037843f6aeb12e236"
}

variable "key_name"{
  type = string
  default= "dfly_eks_instance"
}

variable "aws_profile"{
  type = string
  default= "default"
}
