#Once the cluster is created, this generates the eks_kubeconfig which is the Kubeconfig file in the TF outputs

output "eks_kubeconfig" {
  value      = local.kubeconfig
  depends_on = [aws_eks_cluster.tf_eks]
}
