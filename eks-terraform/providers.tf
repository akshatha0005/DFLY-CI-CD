provider "aws" {
 region = "us-west-2"
}

provider "kubernetes" {
  host                   = aws_eks_cluster.dfly-eks-cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.dfly-eks-cluster.certificate_authority[0].data)
  token                  = data.external.aws_iam_authenticator.result.token
  load_config_file       = true
}
