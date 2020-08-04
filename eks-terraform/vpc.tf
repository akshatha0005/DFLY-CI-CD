#VPC --> in us-west-2 region
#Private subnets in 3 AZ
#Public subnets in 3 AZ
#ROUTE Tables and Security Group to guide traffic in and out of subnets
#ECR repository for hosting Docker Images
#Dynamo DB for handling the state file Locks for collabrative working and sharing of terraform state files
#S3 bucket for storing the state files and versioning capability will add a secure backup option of state files



# VPC for hosting the EKS Cluster
resource "aws_vpc" "eks_vpc" {
  cidr_block       = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.name
  }
}

# Creating 3 Private subnets with the count feature
resource "aws_subnet" "eks_private_subnet" {
  count      = length(var.private_subnets)
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = element(var.private_subnets, count.index)
  map_public_ip_on_launch= false
  availability_zone = element(var.region_zones, count.index)


  tags = {
    "Name"                                      = "eks private subnet"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}

# Creating 3 Public subnets with the count feature
resource "aws_subnet" "eks_public_subnet" {
  count      = length(var.public_subnets)
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = element(var.public_subnets, count.index)
  map_public_ip_on_launch= true
  availability_zone = element(var.region_zones, count.index)

  tags = {
    "Name"                                      = "eks public subnet"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}

#IGW for allowing internet access for the VPC traffic
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name      = "igw-${var.name}"
    terraform = "true"
  }
}

#For internet reachability from private subnets, EIP are needed 1 per subnet.
# they are attached to NAT GATEWAY and NATs are hosted in Public subnet
# NAT GATEWAY are used in Route Tables that are attached to Private subnet.
# so Internet traffic from Private Subnet flows through NAT GATEWAY via Public Subnet
resource "aws_eip" "eks_nat_eips" {
  count = length(var.region_zones)
  vpc   = "true"
}

# Creating NATS that are attached to EIPs
resource "aws_nat_gateway" "eks_nats" {
  count         = length(var.region_zones)
  allocation_id = element(aws_eip.eks_nat_eips.*.id, count.index)
  subnet_id     = element(aws_subnet.eks_public_subnet.*.id, count.index)
  depends_on    = [aws_internet_gateway.eks_igw]
}

#Creating Route Tables to enable the Public Subnet routing capabilities
resource "aws_route_table" "eks_public_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name      = "rt-${var.name}-public"
    terraform = "true"
  }
}

#Creating Route Tables to enable the Private Subnet routing capabilities
resource "aws_route_table" "eks_private_rt" {
  count  = length(var.region_zones)
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = format("rt-public-%s-%d",element(var.region_zones,count.index),floor(count.index/length(var.region_zones)))
  }
}

#Defining  routes  for Public traffic
resource "aws_route" "ek_public_route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks_igw.id
  route_table_id         = aws_route_table.eks_public_rt.id
}

#Definingroutes  for Private traffic
resource "aws_route" "eks_private_route" {
  count                  = length(var.region_zones)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.eks_nats.*.id, count.index)
  route_table_id         = element(aws_route_table.eks_private_rt.*.id, count.index)
}

#Attaching Routes to Route Table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  route_table_id = aws_route_table.eks_public_rt.id
  subnet_id      = element(aws_subnet.eks_public_subnet.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  route_table_id = element(aws_route_table.eks_private_rt.*.id, count.index)
  subnet_id      = element(aws_subnet.eks_private_subnet.*.id, count.index)
}

#For State file locks in Dynamo DB tables
resource "aws_dynamodb_table" "tf_state_lock" {
  name           = "tf-state-lock"
  read_capacity  = 4
  write_capacity = 4
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

#ECR repository for storing the CI builds
resource "aws_ecr_repository" "eks_image_repository" {
  name                 = "dfly_images"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

#Permissions to access the Images in ECR
resource "aws_ecr_repository_policy" "eks_image_repository_policy" {
  repository = aws_ecr_repository.eks_image_repository.name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "new policy",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
EOF
}

#S3 bucket for storing Terraform State files
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "dfly-assesment-tf"
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
