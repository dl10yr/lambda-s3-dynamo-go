locals {
  project_name = "lambda-s3-dynamo-go"
  env          = "dev"
  region       = "ap-northeast-1"
}

provider "aws" {
  region = local.region
}

terraform {
  backend "s3" {
    bucket = "lambda-s3-dynamo-go-tfstate"
    key    = "lambda-s3-dynamo-go-tfstate/dev.tfstate"
    region = "ap-northeast-1"
  }
}

module "dynamodb" {
  source       = "../../modules/dynamodb"
  project_name = local.project_name
  env          = local.env
}

module "iam" {
  source          = "../../modules/iam"
  project_name    = local.project_name
  env             = local.env
  dynamodb_tables = [module.dynamodb.members_table_arn]
}

module "ssm" {
  source       = "../../modules/ssm"
  project_name = local.project_name
  env          = local.env
  role_arn     = module.iam.role_arn
}

# module "s3" {
#   source       = "../../modules/s3"
#   project_name = local.project_name
#   env          = local.env
# }
