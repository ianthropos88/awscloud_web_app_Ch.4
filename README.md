# **Deploy the Application and Database within 3 Environments (Development, Staging, & Production)** :computer: #

In the DevOps world, we sometimes struggle with terminology.

Note: A stage is a stack that you deploy for a specific purpose.

Stages are used in code pipelines to provide an on-ramp to push code changes from smaller to wider audiences. For example, a change will typically start with a dev stage (either a team or a personal dev stack). If the change works on the dev stage, a team may next push it to a test stage where internal stakeholders can access it, followed by a staging stage where it's available to a limited number of external customers. Finally, if the change passes all automated and manual tests, it'll be pushed to the production stage.

Stages can also be referred to as "environments" - for example, the dev environment, test environment, etc.

## > :rocket: **Thank you for your interest in my work.** :blush: ##

This solution aims at deploying a web application with a PostgreSQL database on AWS in 3 environments (Development, Staging, & Production).

The project is supported by several managed services including AWS RDS, PostgreSQL,Amazon ElastiCache, Amazon Elasticsearch Service, Amazon Pinpoint and Amazon Personalize.

## **Full Production, Staging and Dev environments on AWS with Kubernetes and RDS** :pager: ##

This example will show how to deploy a containerized app (Strapi) with PostgreSQL on AWS in Development, Staging and Production and makes it accessible via HTTPS. All of that in just a few lines of Terraform file.

```tr
resource "droplets_aws_credentials" "my_aws_creds" {
  organization_id   = var.droplets_organization_id
  name              = "URL Shortener"
  access_key_id     = var.aws_access_key_id
  secret_access_key = var.aws_secret_access_key
}

resource "droplets_cluster" "production_cluster" {
  organization_id   = var.droplets_organization_id
  credentials_id    = droplets_aws_credentials.my_aws_creds.id
  name              = "Production cluster"
  description       = "Terraform prod demo cluster"
  cloud_provider    = "AWS"
  region            = "us-east-2"
  instance_type     = "T3A_MEDIUM"
  min_running_nodes = 3
  max_running_nodes = 4
  state             = "RUNNING"

  depends_on = [
    droplets_aws_credentials.my_aws_creds
  ]
}

resource "droplets_cluster" "staging_cluster" {
  organization_id   = var.droplets_organization_id
  credentials_id    = droplets_aws_credentials.my_aws_creds.id
  name              = "Staging cluster"
  description       = "Terraform staging demo cluster"
  cloud_provider    = "AWS"
  region            = "us-east-2"
  instance_type     = "T3A_MEDIUM"
  min_running_nodes = 3
  max_running_nodes = 4
  state             = "RUNNING"

  depends_on = [
    droplets_aws_credentials.my_aws_creds
  ]
}

resource "droplets_cluster" "dev_cluster" {
  organization_id   = var.droplets_organization_id
  credentials_id    = droplets_aws_credentials.my_aws_creds.id
  name              = "Dev cluster"
  description       = "Terraform dev demo cluster"
  cloud_provider    = "AWS"
  region            = "eu-central-1"
  instance_type     = "T3A_MEDIUM"
  min_running_nodes = 3
  max_running_nodes = 4
  state             = "RUNNING"

  depends_on = [
    droplets_aws_credentials.my_aws_creds
  ]
}


resource "droplets_project" "my_project" {
  organization_id = var.droplets_organization_id
  name            = "Multi-env Project"

  depends_on = [
    droplets_cluster.production_cluster
  ]
}

resource "droplets_environment" "production" {
  project_id = droplets_project.my_project.id
  name       = "production"
  mode       = "PRODUCTION"
  cluster_id = droplets_cluster.production_cluster.id

  depends_on = [
    droplets_project.my_project
  ]
}

resource "droplets_database" "production_psql_database" {
  environment_id = droplets_environment.production.id
  name           = "strapi db"
  type           = "POSTGRESQL"
  version        = "13"
  mode           = "MANAGED" # Use AWS RDS for PostgreSQL (backup and PITR automatically configured by droplets)
  storage        = 10 # 10GB of storage
  accessibility  = "PRIVATE" # do not make it publicly accessible
  state          = "RUNNING"

  depends_on = [
    droplets_environment.production,
  ]
}

resource "droplets_application" "production_strapi_app" {
  environment_id = droplets_environment.production.id
  name           = "strapi app"
  cpu            = 1000
  memory         = 512
  state          = "RUNNING"
  git_repository = {
    url       = "https://github.com/ianthropos88/awscloud_web_app_Ch.4"
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

  depends_on = [
    droplets_environment.production,
    droplets_database.production_psql_database,
  ]
}
```

**Behind the Scene:**

1. Creates 3 Kubernetes clusters (`Dev`, `Staging`, `Production`) on your AWS account (VPC, Security Groups, Subnet, EKS/Kubernetes...)
2. Creates resources:
   1. Organization `Terraform Demo`
   2. Project `Strapi V4`
   3. Environment `production`
   4. Database `strapi db` (RDS) for `Production`
   5. Application `strapi app` for `Production`
   6. Environment `staging`
   7. Database `strapi db` (RDS) for `Staging`
   8. Application `strapi app` for `Staging`
   9. Environment `dev`
   10. Database `strapi db` (Container with EBS) for `Dev`
   11. Application `strapi app` for `Dev`
   12. Inject all the Secrets and Environment Variables used by the app for every environment
3. Build `strapi app` application for `Production`, `Staging` and `Dev` environments in parallel
4. Pushes `strapi app` container image in your ECR registry  for `Production`, `Staging` and `Dev` environments in parallel
5. Deploys your PostgreSQL database for `Production` (AWS RDS), `Staging` (AWS RDS) and `Dev` (Container) environments in parallel
6. Deploys `strapi app` on your `Production`, `Staging` and `Dev` EKS clusters
7. Creates an AWS Network Load Balancer for all your clusters and apps
8. Generates a TLS certificate for your app for all your apps
9. Exposes publicly via HTTPS your Strapi app from `Production`, `Staging` and `Dev` through different endpoints

It will take approximately **20 minutes to create your infrastructure** and **less than 10 minutes to deploy your application** for each environment. 
