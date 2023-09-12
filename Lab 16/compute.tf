resource "aws_eks_cluster" "demo" {
  name     = "demo"
  role_arn = aws_iam_role.eks-iam-role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.public_subnets[0].id,
      aws_subnet.public_subnets[1].id
    ]
  }

  kubernetes_network_config {
    service_ipv4_cidr = "10.2.0.0/24"
    ip_family = "ipv4"
  }

  depends_on = [
    aws_iam_role.eks-iam-role,
  ]
}

resource "aws_eks_node_group" "worker-node-group" {
  cluster_name      = aws_eks_cluster.demo.name
  node_group_name   = "private-workernodes"
  node_role_arn     = aws_iam_role.worker-nodes-iam-role.arn
  subnet_ids        = [
    aws_subnet.public_subnets[0].id,
    aws_subnet.public_subnets[1].id
  ]
  
  capacity_type = "ON_DEMAND"
  instance_types   = ["t3.small"]
  disk_size = "20"

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}
