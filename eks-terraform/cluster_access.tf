# To configure terraform-kubernetes provider to run the apply for kubernetes_config_map
# it needs token which we can get through this and use it in provider block.


data "external" "aws_iam_authenticator" {
  program = ["sh", "-c", "aws-iam-authenticator token -i ${var.eks_cluster_name} ${var.aws_profile} | jq -r -c .status"]
}

# this will apply the config map which is to update the aws-iam-authenticator user and role
# permissions to access the cluster resources


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
