#SG to access the Cluster Master

resource "aws_security_group" "eks_cluster_sg" {
  name        = "Dfly-eks-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.eks_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks"
  }
}

resource "aws_security_group_rule" "eks_cluster_sg_https" {
  cidr_blocks       = ["76.103.201.185/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_cluster_sg.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "eks_cluster_sg_ingress_node" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_worker_node_sg.id
  to_port                  = 443
  type                     = "ingress"
}


#SG to access the Cluster Worker


resource "aws_security_group" "eks_worker_node_sg" {
  name        = "Dfly-eks-worker-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.eks_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "eks_worker_node_sg_self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_worker_node_sg.id
  source_security_group_id = aws_security_group.eks_worker_node_sg.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_worker_node_sg_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control    plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_worker_node_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  to_port                  = 65535
  type                     = "ingress"
 }
