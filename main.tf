terraform {
    required_version = ">=0.13.1"
    required_providers {
      aws = ">=5.22.0"
      local = ">=2.4.0"
    }
    # Salvando o tfstate no Bucket S3 para evitarmos quebrar
    # o tfstate ao trabalharmos em grupos/squads.
    # OBS 1: Se faz necessário criar o Buckt S3 antes de executar
    # esse trechode código.
    # OBS 2: Ao criar o S3 deixar abilitado o auto versionamento a 
    # cada alteração.
    backend "s3" {
      bucket = "bucket-terraform-cluster"
      key    = "terraform.tfstate"
      region = "us-east-1"
    }
}

provider "aws" {
  region = "us-east-1"
  access_key = ${{ secrets.AWS_ACCESS_KEY_ID }} 
  secret_key = ${{ secrets.AWS_SECRET_ACCESS_KEY }}
}

module "new-vpc" {
  source = "./modules/vpc"
  prefix = var.prefix
  vpc_cidr_block = var.vpc_cidr_block
}

module "eks" {
    source = "./modules/eks"
    prefix = var.prefix
    vpc_id = module.new-vpc.vpc_id
    cluster_name = var.cluster_name
    retention_days = var.retention_days
    subnet_ids = module.new-vpc.subnet_ids
    desired_size = var.desired_size
    max_size = var.max_size
    min_size = var.min_size
}