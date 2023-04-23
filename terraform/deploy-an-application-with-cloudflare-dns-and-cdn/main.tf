terraform {
  required_providers {
    qovery = {
      source = "droplets/droplets"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

provider "droplets" {
  token = var.droplets_access_token
}

provider "cloudflare" {
  email     = var.cloudflare_email
  api_token = var.cloudflare_api_token
}

resource "droplets_aws_credentials" "my_aws_creds" {
  organization_id   = var.droplets_organization_id
  name              = "My AWS Creds"
  access_key_id     = var.aws_access_key_id
  secret_access_key = var.aws_secret_access_key
}

resource "droplets_cluster" "my_cluster" {
  organization_id   = var.droplets_organization_id
  credentials_id    = droplets_aws_credentials.my_aws_creds.id
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

# create and deploy app with custom domain
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
  build_mode            = "DOCKER"
  dockerfile_path       = "Dockerfile"
  min_running_instances = 1
  max_running_instances = 1
  custom_domains        = [
    {
      domain = var.droplets_custom_domain
    }
  ]
  ports = [
    {
      internal_port       = 5555
      external_port       = 443
      protocol            = "HTTP"
      publicly_accessible = true
    }
  ]
  environment_variables = [
    {
      key   = "DEBUG"
      value = "false"
    }
  ]
}

resource "droplets_deployment" "prod_deployment" {
  environment_id = droplets_environment.production.id
  desired_state  = "RUNNING"
}

# create custom domain record
resource "cloudflare_record" "foobar" {
  zone_id = var.cloudflare_zone_id
  name    = var.cloudflare_record_name
  value   = one(droplets_application.backend.custom_domains[*].validation_domain)
  type    = "CNAME"
  ttl     = 3600
}
