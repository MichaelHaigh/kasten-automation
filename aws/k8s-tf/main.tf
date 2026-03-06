terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.35.1"
    }
    #cloudinit = {
    #  source = "hashicorp/cloudinit"
    #  version = "~> 2.3.7"
    #}
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3.5"
    }
    http = {
      source = "hashicorp/http"
      #version = "~> 3.4.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.8.1"
    }
  }
}

provider "aws" {
  region = var.aws_region

  access_key = jsondecode(file(var.aws_cred_file)).aws_access_key_id
  secret_key = jsondecode(file(var.aws_cred_file)).aws_secret_access_key
  # token      = jsondecode(file(var.aws_cred_file)).aws_session_token
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.eks_cluster.name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
