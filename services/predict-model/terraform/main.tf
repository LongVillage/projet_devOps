###########################################################
# main.tf
###########################################################

#################################
# VPC
#################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b"
  ]

  public_subnets  = var.public_subnets_cidr
  private_subnets = var.private_subnets_cidr
  enable_nat_gateway = true

  tags = {
    Project = "crypto-project"
  }
}

#################################
# EKS IAM / OIDC
#################################
# EKS cluster IAM + NodeGroup IAM
data "aws_iam_policy_document" "eks_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_trust.json
}
resource "aws_iam_role_policy_attachment" "eks_cluster_attach1" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_iam_role_policy_attachment" "eks_cluster_attach2" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

data "aws_iam_policy_document" "ec2_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "eks_node_role" {
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}
resource "aws_iam_role_policy_attachment" "node_attach1" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "node_attach2" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "node_attach3" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

#################################
# EKS Cluster + NodeGroup
#################################
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.k8s_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = module.vpc.public_subnets
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_attach1,
    aws_iam_role_policy_attachment.eks_cluster_attach2
  ]
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  node_group_name = "${var.cluster_name}-ng"

  subnet_ids = module.vpc.private_subnets

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  depends_on = [
    aws_eks_cluster.this,
    aws_iam_role_policy_attachment.node_attach1,
    aws_iam_role_policy_attachment.node_attach2,
    aws_iam_role_policy_attachment.node_attach3
  ]
}

#################################
# Data sources EKS
#################################
data "aws_eks_cluster" "cluster" {
  name       = aws_eks_cluster.this.name
  depends_on = [aws_eks_cluster.this]
}
data "aws_eks_cluster_auth" "cluster" {
  name       = aws_eks_cluster.this.name
  depends_on = [aws_eks_cluster.this]
}

#################################
# OIDC Provider pour IRSA (facultatif)
#################################
resource "aws_iam_openid_connect_provider" "oidc" {
  count = var.associate_iam_oidc ? 1 : 0

  # Extraction de l'hôte OIDC uniquement (sans HTTPS ni /id/…)
  url = regex(
    replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", ""),
    "([^/]+)"
  )

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960f8cbb5eaf0f9533d0f7836cb63e5"] # 40 caractères
}

#################################
# Configurer provider.kubernetes alias=eks
# => On fait un "override" ici
#################################
provider "kubernetes" {
  alias = "eks"

  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
}

#################################
# Configurer provider.helm alias=eks_helm
# => On s'appuie sur data EKS
#################################
provider "helm" {
  alias = "eks_helm"

  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  }
}

#################################
# Helm : AWS LB Controller
#################################
resource "helm_release" "aws_load_balancer_controller" {
  provider = helm.eks_helm

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.5.1"

  namespace = "kube-system"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "region"
    value = var.aws_region
  }
  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  depends_on = [
    aws_eks_node_group.this,
  ]
}
