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
  name            = "Cron-job"
}

resource "droplets_environment" "production" {
  project_id = droplets_project.my_project.id
  name       = "production"
  mode       = "PRODUCTION"
  cluster_id = droplets_cluster.my_cluster.id
}

# create and deploy cron job
resource "droplets_job" "cron-job" {
  environment_id = droplets_environment.production.id
  name           = "cron-job"
  
  cpu = 100
  memory = 350
  
  max_duration_seconds = 60
  max_nb_restart = 1
  
  port = 4000
  
  auto_preview = false
  
  schedule = {
    cronjob = {
      schedule = "*/2 * * * *" # every 2 minutes
      command = {
        entrypoint = ""
        arguments = []
      }
    }
  }
  
  source = {
    docker = {
      dockerfile_path = "Dockerfile"
      git_repository = {
        url = "https://github.com/ianthropos88/aws_web_app"
        branch = "job-echo-n-seconds"
        root_path = "/"
      }
    }
  }

  environment_variables = [
      {
        key   = "PORT"
        value = "4000"
      },
      {
        key   = "DURATION_SECONDS"
        value = "15"
      },
  ]

  secrets = [
      {
        key   = "JOB_SECRET"
        value = "my job secret"
      },
  ]
}

resource "droplets_deployment" "prod_deployment" {
  environment_id = droplets_environment.production.id
  desired_state  = "RUNNING"
}
