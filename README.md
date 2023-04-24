# **Deploy the Application and Database within 3 Environments (Development, Staging, & Production)** :computer: #

In the DevOps world, we sometimes struggle with terminology.

Note: A stage is a stack that you deploy for a specific purpose.

Stages are used in code pipelines to provide an on-ramp to push code changes from smaller to wider audiences. For example, a change will typically start with a dev stage (either a team or a personal dev stack). If the change works on the dev stage, a team may next push it to a test stage where internal stakeholders can access it, followed by a staging stage where it's available to a limited number of external customers. Finally, if the change passes all automated and manual tests, it'll be pushed to the production stage.

Stages can also be referred to as "environments" - for example, the dev environment, test environment, etc.

## > :rocket: **Thank you for your interest in my work.** :blush: ##

Using this solution, you can easily set up and manage an entire CI/CD pipeline in AWS accounts using the native AWS suite of CI/CD services, where a commit or change to code passes through various automated stage gates all the way from building and testing to deploying applications, from development to production environments.

The project is supported by several managed services including **Amazon Route 53**, **Amazon CloudFront**, **AWS WAF**, **Elastic Load Balancing (ELB)**, **AWS Shield**, **Amazon ElastiCache**, **Amazon RDS**, **Amazon S3**, etc.

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
  region            = "eu-central-1"
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
  region            = "eu-central-1"
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

### **Behind the Scene** ###

1. Creates 3 Kubernetes clusters (`Dev`, `Staging`, `Production`) on the AWS account (VPC, Security Groups, Subnet, EKS/Kubernetes...).
2. Creates resources:
   - Organization `Terraform Demo`
   - Project `Strapi V4`
   - Environment `production`
   - Database `strapi db` (RDS) for `Production`
   - Application `strapi app` for `Production`
   - Environment `staging`
   - Database `strapi db` (RDS) for `Staging`
   - Application `strapi app` for `Staging`
   - Environment `dev`
   - Database `strapi db` (Container with EBS) for `Dev`
   - Application `strapi app` for `Dev`
   - Inject all the Secrets and Environment Variables used by the app for every environment
3. Builds `strapi app` application for `Production`, `Staging` and `Dev` environments in parallel.
4. Pushes `strapi app` container image in the ECR registry  for `Production`, `Staging` and `Dev` environments in parallel.
5. Deploys your PostgreSQL database for `Production` (AWS RDS), `Staging` (AWS RDS) and `Dev` (Container) environments in parallel.
6. Deploys `strapi app` on your `Production`, `Staging` and `Dev` EKS clusters.
7. Creates an AWS Network Load Balancer for all your clusters and apps.
8. Generates a TLS certificate for your app for all your apps.
9. Exposes publicly via HTTPS your Strapi app from `Production`, `Staging` and `Dev` through different endpoints.

It takes approximately **20 minutes to create the infrastructure** and **less than 10 minutes to deploy the application** for each environment. 

### **AWS services** ###

**This solution uses the following AWS services:**

1. **AWS CodeCommit** – A fully-managed source control service that hosts secure Git-based repositories. CodeCommit makes it easy for teams to collaborate on code in a secure and highly scalable ecosystem. This solution uses CodeCommit to create a repository to store the application and deployment codes.
2. **AWS CodeBuild** – A fully managed continuous integration service that compiles source code, runs tests, and produces software packages that are ready to deploy, on a dynamically created build server. This solution uses CodeBuild to build and test the code, which we deploy later.
3. **AWS CodeDeploy** – A fully managed deployment service that automates software deployments to a variety of compute services such as Amazon EC2, AWS Fargate, AWS Lambda, and your on-premises servers. This solution uses CodeDeploy to deploy the code or application onto a set of EC2 instances running CodeDeploy agents.
4. **AWS CodePipeline** – A fully managed continuous delivery service that helps you automate your release pipelines for fast and reliable application and infrastructure updates. This solution uses CodePipeline to create an end-to-end pipeline that fetches the application code from CodeCommit, builds and tests using CodeBuild, and finally deploys using CodeDeploy.
5. **AWS CloudWatch Events** – An AWS CloudWatch Events rule is created to trigger the CodePipeline on a Git commit to the CodeCommit repository.
Amazon Simple Storage Service (Amazon S3) – An object storage service that offers industry-leading scalability, data availability, security, and performance. This solution uses an S3 bucket to store the build and deployment artifacts created during the pipeline run.
6. **AWS Key Management Service (AWS KMS)** – AWS KMS makes it easy for you to create and manage cryptographic keys and control their use across a wide range of AWS services and in your applications. This solution uses AWS KMS to make sure that the build and deployment artifacts stored on the S3 bucket are encrypted at rest.

### **Overview of solution** ###

This solution uses three separate AWS accounts: a development account (1111), a stage account, and a production account (2222) in Region eu-central-1.

We use the development account to deploy and set up the CI/CD pipeline, along with the source code repository. It also builds and tests the code locally and performs a test deploy.

The production account is any other account where the application is required to be deployed from the pipeline in the dev account.

**In summary, the solution has the following workflow:**

1. A change or commit to the code in the CodeCommit application repository triggers CodePipeline with the help of a CloudWatch event.

2. The pipeline downloads the code from the CodeCommit repository, initiates the Build and Test action using CodeBuild, and securely saves the built artifact in the S3 bucket.

3. If the preceding step is successful, the pipeline triggers the Deploy in Development action using CodeDeploy and deploys the app in development account.

4. If successful, the pipeline triggers the Deploy in Staging action using CodeDeploy and deploys the app in the Staging account. Also, once successful, the pipeline triggers the Deploy in Production action using CodeDeploy and deploys the app in the Production account.

The following diagram illustrates the workflow:

<p align="center">
  <img align="center" src="image/static/Cloud_Architecture_3_Stages.png" width=100%>
</p>
<p align="center"><b>Scenario:</b> The Architecture Design - 3 Tier within 3 Environments (Development, Stage and Production).</p>
