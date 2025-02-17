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
  # (Optionnel) backend "s3" { ... } si tu veux stocker le state dans S3
}

# Provider AWS
# On suppose que tu mets tes credentials via variable GitLab
# (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY).
# AWS_REGION sera passé en TF_VAR_aws_region ou dans terraform.tfvars
provider "aws" {
  region = var.aws_region
}

# Provider kubernetes
# On n'a PAS besoin de "kube_host/kube_token/kube_ca" manuellement,
# car on va utiliser data sources EKS pour auto-récupérer ces infos.
# => Voir main.tf (on fera host/token/ca dynamiquement).
provider "kubernetes" {
  host                   = var.k8s_host        # à renseigner si tu veux
  token                  = var.k8s_token       # idem
  cluster_ca_certificate = base64decode(var.k8s_ca)
  # On le surchargera plus loin via alias (voir la technique data sources).
}

# Provider helm
provider "helm" {
  kubernetes {
    host                   = var.k8s_host
    token                  = var.k8s_token
    cluster_ca_certificate = base64decode(var.k8s_ca)
  }
}
