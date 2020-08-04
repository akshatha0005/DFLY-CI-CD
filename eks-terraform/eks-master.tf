
resource "aws_eks_cluster" "dfly-eks-cluster" {
  name            = var.eks_cluster_name
  role_arn        = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
    subnet_ids         = aws_subnet.eks_public_subnet.*.id
  }

  depends_on = [
    "aws_iam_role_policy_attachment.dfly-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.dfly-cluster-AmazonEKSServicePolicy"
  ]
}
