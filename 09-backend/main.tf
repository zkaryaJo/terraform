terraform {

# 1.S3 backend : requirements - bucket(global unique key), key, region

/*
  backend "s3" {
    bucket = "zkaryajo-deveops-terraform"
    key    = "s3-backend/terraform.tfstate"
    region = "ap-northeast-2"
  }
*/

# 2. Terraform Cloud : requirements - hostname, organization, workspaces
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "zkaryajo-test"

    workspaces {
      name = "tf-cloud-backend"
    }
  }

}

provider "aws" { 
  region = "ap-northeast-2"
}

resource "aws_iam_group" "developer" {
  name = "developer"
}

resource "aws_iam_group" "employee" {
  name = "employee"
}

output "groups" {
  value = [
    aws_iam_group.developer,
    aws_iam_group.employee,
  ]
}

variable "users" {
  type = list(any)
}

resource "aws_iam_user" "this" {

  for_each = {
    for user in var.users : 
      user.name => user
  }

  name = each.key

  tags = {
    level = each.value.level
    role = each.value.role
  }
}

resource "aws_iam_user_group_membership" "this" {
  for_each = {
    for user in var.users :
      user.name => user
  }
  
  user = each.key
  groups = each.value.is_developer ? [aws_iam_group.developer.name, aws_iam_group.employee.name] : [aws_iam_group.employee.name]

}

locals {
  developers = [
    for user in var.users : 
      user
      if user.is_developer
  ]
}

resource "aws_iam_user_policy_attachment" "developer" {
  for_each = {
    for user in local.developers : 
    user.name => user
  }

  user = each.key
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

  depends_on = [
    aws_iam_user.this
  ]
}

output "developers" {
  value = local.developers
}

output "high_level_users" {
  value = [
    for user in var.users : 
    user
    if user.level > 5
  ]
}
