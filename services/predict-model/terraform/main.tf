###########################################################
# main.tf
###########################################################
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

##############################
# IAM / OIDC for EKS
##############################
resource "aws_iam_openid_connect_provider" "oidc" {
  depends_on = [aws_eks_cluster.this]
  # On attend la création du cluster pour récupérer l'issuer
  url = replace(data.aws_eks_cluster.cluster.identity[0].oidc.issuer, "https://", "")
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960f8cbb5eaf###"] # => Valeur par défaut AWS EKS OIDC
  # Cf doc: https://docs.aws.amazon.com/eks/latest/userguide/associate-iam-oidc-provider.html
  # On doit la faire pointer sur le cluster
  # On le fera "if" (associate_iam_oidc) => sinon, ressource compte pas
  count = var.associate_iam_oidc ? 1 : 0
}

##############################
# EKS IAM roles
##############################
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

##############################
# EKS Cluster
##############################
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

##############################
# Node Group (dans subnets privés)
##############################
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

##############################
# Data sources: EKS endpoint + CA + token
##############################
data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.this.name
  depends_on = [aws_eks_cluster.this]
}
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.this.name
  depends_on = [aws_eks_cluster.this]
}

##############################
# Reconfigurer le provider kubernetes (alias)
##############################
provider "kubernetes" {
  alias = "eks"
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
}

##############################
# Helm : AWS LB Controller
##############################
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.5.1"  # ex.

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

  # On utilise le provider kubernetes (alias = "eks") qu'on vient de configurer
  # => On se connecte à ce nouveau cluster
  provider = kubernetes.eks

  depends_on = [
    aws_eks_node_group.this,
  ]
}
