# ─────────────────────────────────────────────────────────────
# Terraform Block: Declares required providers and versions
# ─────────────────────────────────────────────────────────────
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"   # Specifies the AWS provider source
      version = "6.13.0"          # Locks provider version for reproducibility
    }
  }
}

# ─────────────────────────────────────────────────────────────
# AWS Provider Configuration: Sets region and credentials context
# ─────────────────────────────────────────────────────────────
provider "aws" {
  region = "eu-north-1"  # Deploys resources in Stockholm region
  # Credentials will be sourced from environment variables, shared config, or IAM role
}
