# Amazon EKS uses IAM to provide authentication to your Kubernetes cluster through the AWS IAM authenticator for Kubernetes.
# You can configure the stock kubectl client to work with Amazon EKS by installing
# the AWS IAM authenticator for Kubernetes and modifying your kubectl configuration file to use it for authentication.



# save the 'terraform output eks_kubeconfig > config', run 'mv config ~/.kube/config' to use it for kubectl


locals {
  kubeconfig = <<KUBECONFIG

apiVersion: v1
clusters:
- cluster:
    server: "aws_eks_cluster.dfly-eks-cluster.endpoint"
    certificate-authority-data: "aws_eks_cluster.tf_eks.certificate_authority[0].data"
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "var.eks_cluster_name"
        - "var.aws_profile"
KUBECONFIG

}

#certificate-authority-data: is created by AWS EKS for the cluster
#aws-iam-authenticator (To always use a specific named AWS credential profile)


# authenticator configuration map will show each role and user groups and the policies attached to it
# it can be edited to add or remove permissions on cluster resources
# it is also used to give access to visualize the cluster resources to a user account in DFLY-CI-CD/eks-terraform/cluster_join.tf file.
