###########################################################
# variables.tf
###########################################################
variable "aws_region" {
  type        = string
  default     = "eu-west-3"
  description = "Région AWS à utiliser"
}

variable "cluster_name" {
  type        = string
  default     = "myekscrypto"
  description = "Nom du cluster EKS"
}

variable "k8s_version" {
  type        = string
  default     = "1.27"
  description = "Version K8s pour EKS"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR global de la VPC"
}

variable "public_subnets_cidr" {
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
  description = "CIDRs pour subnets publics"
}

variable "private_subnets_cidr" {
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
  description = "CIDRs pour subnets privés"
}

# IRSA / OIDC
variable "associate_iam_oidc" {
  type        = bool
  default     = true
  description = "Si true, on associe l'OIDC provider pour IRSA"
}

# Optionnel: si tu veux paramétrer manuellement le provider K8s
variable "k8s_host" {
  type        = string
  default     = ""
  description = "Endpoint K8s (optionnel, on va lire data source EKS si single apply)"
}

variable "k8s_token" {
  type        = string
  default     = ""
  description = "Token K8s (optionnel)"
  sensitive   = true
}

variable "k8s_ca" {
  type        = string
  default     = ""
  description = "Certif CA base64 (optionnel)"
  sensitive   = true
}
