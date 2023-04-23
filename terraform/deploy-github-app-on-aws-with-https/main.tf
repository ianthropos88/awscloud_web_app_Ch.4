terraform {
  required_providers {
    droplets = {
      source = "droplets/droplets"
    }
  }
}

provider "droplets" {
  token = var.droplets_access_token
}

resource "droplets_aws_credentials" "my_aws_creds_2" {
  organization_id   = var.droplets_organization_id
  name              = "My AWS Creds"
  access_key_id     = var.aws_access_key_id
  secret_access_key = var.aws_secret_access_key
}

resource "droplets_cluster" "my_cluster" {
  organization_id   = var.droplets_organization_id
  credentials_id    = droplets_aws_credentials.my_aws_creds_2.id
  name              = "Demo cluster"
  description       = "Terraform demo cluster"
  cloud_provider    = "AWS"
  region            = "eu-central-1"
  instance_type     = "t3a.medium"
  min_running_nodes = 3
  max_running_nodes = 4
}

resource "droplets_project" "my_project" {
  organization_id = var.droplets_organization_id
  name            = "URL Shortener"
}

resource "droplets_environment" "production" {
  project_id = droplets_project.my_project.id
  name       = "production"
  mode       = "PRODUCTION"
  cluster_id = droplets_cluster.my_cluster.id
}

resource "droplets_application" "backend" {
  environment_id = droplets_environment.production.id
  name           = "backend"
  cpu            = 500
  memory         = 256
  git_repository = {
    url       = "https://github.com/ianthropos88/aws_web_app"
    branch    = "main"
    root_path = "/"
  }
  build_mode            = "BUILDPACKS"
  buildpack_language    = "PYTHON"
  min_running_instances = 1
  max_running_instances = 1
  ports                 = [
    {
      internal_port       = 3333
      external_port       = 443
      protocol            = "HTTP"
      publicly_accessible = true
    }
  ]
  environment_variables = [
    {
      key   = "PORT"
      value = "3333"
    },
    {
      key   = "DEBUG"
      value = "false"
    }
  ]
}
