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

resource "droplets_cluster" "production_cluster" {
  organization_id   = var.droplets_organization_id
  credentials_id    = droplets_aws_credentials.my_aws_creds.id
  name              = "Production cluster"
  description       = "Terraform prod demo cluster"
  cloud_provider    = "AWS"
  region            = "eu-central-1"
  instance_type     = "t3a.medium"
  min_running_nodes = 3
  max_running_nodes = 4
}

resource "droplets_cluster" "staging_cluster" {
  organization_id   = var.droplets_organization_id
  credentials_id    = droplets_aws_credentials.my_aws_creds.id
  name              = "Staging cluster"
  description       = "Terraform staging demo cluster"
  cloud_provider    = "AWS"
  region            = "eu-central-1"
  instance_type     = "t3a.medium"
  min_running_nodes = 3
  max_running_nodes = 4
}

resource "droplets_cluster" "dev_cluster" {
  organization_id   = var.droplets_organization_id
  credentials_id    = droplets_aws_credentials.my_aws_creds.id
  name              = "Dev cluster"
  description       = "Terraform dev demo cluster"
  cloud_provider    = "AWS"
  region            = "eu-central-1"
  instance_type     = "t3a.medium"
  min_running_nodes = 3
  max_running_nodes = 4
}


resource "droplets_project" "my_project" {
  organization_id = var.droplets_organization_id
  name            = "Multi-env Project"
}

resource "droplets_environment" "production" {
  project_id = droplets_project.my_project.id
  name       = "production"
  mode       = "PRODUCTION"
  cluster_id = droplets_cluster.production_cluster.id
}

resource "droplets_database" "production_psql_database" {
  environment_id = droplets_environment.production.id
  name           = "strapi db"
  type           = "POSTGRESQL"
  version        = "13"
  mode           = "MANAGED" # Use AWS RDS for PostgreSQL (backup and PITR automatically configured by droplets)
  storage        = 10 # 10GB of storage
  accessibility  = "PRIVATE" # do not make it publicly accessible
}

resource "droplets_application" "production_strapi_app" {
  environment_id = droplets_environment.production.id
  name           = "strapi app"
  cpu            = 1000
  memory         = 512
  git_repository = {
    url       = "https://github.com/ianthropos88/aws_web_app"
    branch    = "main"
    root_path = "/"
  }
  build_mode            = "DOCKER"
  dockerfile_path       = "Dockerfile"
  min_running_instances = 1
  max_running_instances = 1
  ports                 = [
    {
      internal_port       = 1337
      external_port       = 443
      protocol            = "HTTP"
      publicly_accessible = true
    }
  ]
  environment_variables = [
    {
      key   = "PORT"
      value = "1337"
    },
    {
      key   = "HOST"
      value = "0.0.0.0"
    },
    {
      key   = "DATABASE_HOST"
      value = droplets_database.production_psql_database.internal_host
    },
    {
      key   = "DATABASE_PORT"
      value = droplets_database.production_psql_database.port
    },
    {
      key   = "DATABASE_USERNAME"
      value = droplets_database.production_psql_database.login
    },
    {
      key   = "DATABASE_NAME"
      value = "postgres"
    },
  ]
  secrets = [
    {
      key   = "ADMIN_JWT_SECRET"
      value = var.strapi_admin_jwt_secret
    },
    {
      key   = "API_TOKEN_SALT"
      value = var.strapi_api_token_salt
    },
    {
      key   = "APP_KEYS"
      value = var.strapi_app_keys
    },
    {
      key   = "DATABASE_PASSWORD"
      value = droplets_database.production_psql_database.password
    }
  ]
}

resource "droplets_deployment" "prod_deployment" {
  environment_id = droplets_environment.production.id
  desired_state  = "RUNNING"
}

resource "droplets_environment" "staging" {
  project_id = droplets_project.my_project.id
  name       = "staging"
  mode       = "STAGING"
  cluster_id = droplets_cluster.staging_cluster.id
}

resource "droplets_database" "staging_psql_database" {
  environment_id = droplets_environment.staging.id
  name           = "strapi db"
  type           = "POSTGRESQL"
  version        = "13"
  mode           = "MANAGED" # Use AWS RDS for PostgreSQL (backup and PITR automatically configured by Qovery)
  storage        = 10 # 10GB of storage
  accessibility  = "PRIVATE" # do not make it publicly accessible
}

resource "droplets_application" "staging_strapi_app" {
  environment_id = droplets_environment.staging.id
  name           = "strapi app"
  cpu            = 1000
  memory         = 512
  git_repository = {
    url       = "https://github.com/ianthropos88/aws_web_app"
    branch    = "main"
    root_path = "/"
  }
  build_mode            = "DOCKER"
  dockerfile_path       = "Dockerfile"
  min_running_instances = 1
  max_running_instances = 1
  ports                 = [
    {
      internal_port       = 1337
      external_port       = 443
      protocol            = "HTTP"
      publicly_accessible = true
    }
  ]
  environment_variables = [
    {
      key   = "PORT"
      value = "1337"
    },
    {
      key   = "HOST"
      value = "0.0.0.0"
    },
    {
      key   = "DATABASE_HOST"
      value = droplets_database.staging_psql_database.internal_host
    },
    {
      key   = "DATABASE_PORT"
      value = droplets_database.staging_psql_database.port
    },
    {
      key   = "DATABASE_USERNAME"
      value = droplets_database.staging_psql_database.login
    },
    {
      key   = "DATABASE_NAME"
      value = "postgres"
    },
  ]
  secrets = [
    {
      key   = "ADMIN_JWT_SECRET"
      value = var.strapi_admin_jwt_secret
    },
    {
      key   = "API_TOKEN_SALT"
      value = var.strapi_api_token_salt
    },
    {
      key   = "APP_KEYS"
      value = var.strapi_app_keys
    },
    {
      key   = "DATABASE_PASSWORD"
      value = droplets_database.staging_psql_database.password
    }
  ]
}

resource "droplets_deployment" "staging_deployment" {
  environment_id = droplets_environment.staging.id
  desired_state  = "RUNNING"
}

resource "droplets_environment" "dev" {
  project_id = droplets_project.my_project.id
  name       = "dev"
  mode       = "DEVELOPMENT"
  cluster_id = droplets_cluster.dev_cluster.id
}

resource "droplets_database" "dev_psql_database" {
  environment_id = droplets_environment.dev.id
  name           = "strapi db"
  type           = "POSTGRESQL"
  version        = "13"
  mode           = "CONTAINER" # Use a container for development purpose
  storage        = 10 # 10GB of storage
  accessibility  = "PRIVATE" # do not make it publicly accessible
}

resource "droplets_application" "dev_strapi_app" {
  environment_id = droplets_environment.staging.id
  name           = "strapi app"
  cpu            = 1000
  memory         = 512
  git_repository = {
    url       = "https://github.com/ianthropos88/aws_web_app"
    branch    = "main"
    root_path = "/"
  }
  build_mode            = "DOCKER"
  dockerfile_path       = "Dockerfile"
  min_running_instances = 1
  max_running_instances = 1
  ports                 = [
    {
      internal_port       = 1337
      external_port       = 443
      protocol            = "HTTP"
      publicly_accessible = true
    }
  ]
  environment_variables = [
    {
      key   = "PORT"
      value = "1337"
    },
    {
      key   = "HOST"
      value = "0.0.0.0"
    },
    {
      key   = "DATABASE_HOST"
      value = droplets_database.dev_psql_database.internal_host
    },
    {
      key   = "DATABASE_PORT"
      value = droplets_database.dev_psql_database.port
    },
    {
      key   = "DATABASE_USERNAME"
      value = droplets_database.dev_psql_database.login
    },
    {
      key   = "DATABASE_NAME"
      value = "postgres"
    },
  ]
  secrets = [
    {
      key   = "ADMIN_JWT_SECRET"
      value = var.strapi_admin_jwt_secret
    },
    {
      key   = "API_TOKEN_SALT"
      value = var.strapi_api_token_salt
    },
    {
      key   = "APP_KEYS"
      value = var.strapi_app_keys
    },
    {
      key   = "DATABASE_PASSWORD"
      value = droplets_database.dev_psql_database.password
    }
  ]
}

resource "droplets_deployment" "dev_deployment" {
  environment_id = droplets_environment.dev.id
  desired_state  = "RUNNING"
}
