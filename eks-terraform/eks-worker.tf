
locals {
eks-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
TAG_NAME="Name"
INSTANCE_ID="`wget -qO- http://instance-data/latest/meta-data/instance-id`"
REGION="`wget -qO- http://instance-data/latest/meta-data/placement/availability-zone | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
TAG_VALUE="`aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=$TAG_NAME" --region $REGION --output=text | cut -f5`"
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.dfly-eks-cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.dfly-eks-cluster.certificate_authority[0].data}' '${var.eks_cluster_name}'  --kubelet-extra-args --node-labels=nodepool="$TAG_VALUE"
USERDATA

}

resource "aws_launch_configuration" "eks_worker_launch_config" {
  iam_instance_profile        = aws_iam_instance_profile.dfly-worker-profile.name
  image_id                    = var.ami_id
  instance_type               = var.instance_type
  name_prefix                 = "DFLY-eks"
  security_groups             = [aws_security_group.eks_worker_node_sg.id]
  user_data_base64            = base64encode(local.eks-node-userdata)
  key_name                    = var.key_name
  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "eks_worker_asg" {
  desired_capacity     = var.desired_size
  launch_configuration = aws_launch_configuration.eks_worker_launch_config.id
  max_size             = var.max_worker_nodes
  min_size             = var.min_worker_nodes
  name                 = "dfly-worker-asg"
  vpc_zone_identifier  = aws_subnet.eks_public_subnet.*.id

  tag {
    key                 = "Name"
    value               = "DFLY worker node"
    propagate_at_launch = true
  }
  tag {
    key                 = join("/", ["kubernetes.io", "cluster", var.eks_cluster_name])
    value               = "owned"
    propagate_at_launch = true
  }
  tag {
    key                 = join("/", ["kubernetes.io", "cluster-autoscaler", "enabled"])
    value               = "true"
    propagate_at_launch = true
  }
  tag {
    key                 = join("/", ["kubernetes.io", "cluster-autoscaler", var.eks_cluster_name])
    value               = "owned"
    propagate_at_launch = true
  }
  tag {
    key                 = join("/", ["k8s.io", "cluster", var.eks_cluster_name])
    value               = "owned"
    propagate_at_launch = true
  }
  tag {
    key                 = join("/", ["k8s.io", "cluster-autoscaler", "enabled"])
    value               = "true"
    propagate_at_launch = true
  }
  tag {
    key                 = join("/", ["k8s.io", "cluster-autoscaler", var.eks_cluster_name])
    value               = "owned"
    propagate_at_launch = true
  }
}
