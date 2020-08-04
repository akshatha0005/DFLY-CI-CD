data "external" "aws_iam_authenticator" {
  program = ["sh", "-c", "aws-iam-authenticator token -i ${var.eks_cluster_name} | jq -r -c .status"]
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = <<EOF
    - rolearn: ${aws_iam_role.eks_worker_node_role.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    EOF

   mapUsers = <<EOT
   - rolearn: arn:aws:iam::816360740237:role/dfly-eks-cluster-role
     userarn: arn:aws:iam::816360740237:user/tf-keys
     username: tf-keys
     groups:
        - system:masters
   EOT
   }
  depends_on = [aws_eks_cluster.dfly-eks-cluster]
}
