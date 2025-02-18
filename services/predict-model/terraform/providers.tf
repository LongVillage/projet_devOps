###########################################################
# providers.tf
###########################################################

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5"
    }
  }
  # (Optionnel) backend "s3" { ... } si tu veux stocker tfstate dans S3
}

############################################
# Provider AWS
############################################
provider "aws" {
  region = var.aws_region
}

############################################
# Provider Kubernetes (alias "eks")
# (OPTIONNEL si on veut manipuler des ressources K8s)
############################################
provider "kubernetes" {
  alias = "eks"

  # On va plus loin dans main.tf pour lier host/token/CA
  # via data.aws_eks_cluster, data.aws_eks_cluster_auth
}

############################################
# Provider Helm (alias "eks_helm")
############################################
provider "helm" {
  alias = "eks_helm"

  # On va également configurer dans main.tf
  # kubernetes { host/token/CA }
}
