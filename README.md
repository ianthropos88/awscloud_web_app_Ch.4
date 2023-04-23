# Improve the availability of Operational and Regulatory Information, which inspires high levels of scalability and performance with AWS Cloud. 📲 #

The purpose of this project was to create a Web Application where all the concerned teams can find the right information related to their Operational and Regulatory Information.

## > :rocket: **Thank you for your interest in my work.** :blush:

This solution aims at deploying a web application with a PostgreSQL database on AWS in 3 environments (Development, Staging, & Production).

The project is supported by several managed services including AWS RDS, PostgreSQL,Amazon ElastiCache, Amazon Elasticsearch Service, Amazon Pinpoint and Amazon Personalize..

# Web App Optimization 🚶‍♂️ #

## ✔️ Problem Statement ##

We faced 3 different issues, that might have highly similar root causes:

1. Finished Operational Test Results Required, is sent to the officials with wrong denomination of the destination country or the subjects to be declared free from or to be tested.
2. Shipment documentation does not match with country requirements.
3. Bag print or layout is not in line with the country's request.

On the Regulatory Document, we did not have a tool. On the transport documentation we had a tool, however, we faced accuracy issues with it. In case of the bag print, a project was pulled together but still some countries were kept out of scope.

In a similar case, few regulatory information were recorded from Jan 2020, but we knew that, not all the cases were registered and they were only reported by emails.

#### ✔️ Objectives ####

Create a highly scalable Web App with a distributed relational database, where all the concerned teams can find the right information related to the Regulatory information to request, bag layout, and the transport documentation. All the information needed to be related to the Initial Article Number and it must have been able to track when the changes were done.

#### ✔️ Scope ####

**1st Phase:** 2 Commercial Crops

**2nd Phase:** Include Other Crops

**Not In Scope:** NA

#### ✔️ Deliverables ####

1. Flow Process: AS IS
2. Flow Process: Future State
3. Web Interface Tool Accessible for all Stakeholders
4. Clear Roles in the Process - DACI

#### ✔️ Critical Success Factors ####

1. Management of Change.
2. Countries Ownership of the Process.
3. Good Application from the database to the Production Sites.

#### ✔️ Measures: KPIs & Benefits ####

1. Non-conformities due to wrong delivery documentation.
2. Waiting time for Regulatory Document Corrections.
3. Bag printing issues and financial consequences (rework, manual relabeling, etc.).

#### ✔️ Issues and Risks ####

- Input collection accuracy and in-time records.

# Deploy the Application and Database within 3 Environments (Development, Staging, Production)

This example will show how to deploy a containerized app (Strapi) with PostgreSQL on AWS in Development, Staging and Production and makes it accessible via HTTPS. All of that in just a few lines of Terraform file.

## Behind the scene

Behind the scene:

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

##  **Initiation: Data Flow** :bookmark_tabs: ##

**Web App Data Flow:**

<p align="center">
  <img align="center" src="image/static/Data_Flow.png" width=100%>
</p>
<p align="center"><b>Scenario 1:</b> The Web App Data Flow.</p>

##  **Architecture: AWS Cloud** :cloud: ##

**Project Plan:**

<p align="center">
  <img align="center" src="image/static/AWS_Cloud_Architecture-Project Plan.png" width=100%>
</p>
<p align="center"><b>Scenario 2:</b> The Project Plan - AWS Cloud.</p>

**Architecture Design - 3 Tier Single Region:**

The following figure provides a look at the classic web application architecture and how it can leverage the AWS Cloud computing infrastructure.

<p align="center">
  <img align="center" src="image/static/AWS_Cloud_Architecture-Single Region.png" width=100%>
</p>
<p align="center"><b>Scenario 3:</b> The Architecture Design - 3 Tier Single Region.</p>

*System Overview:*

1. **DNS services with Amazon Route 53** – Provides DNS services to simplify domain management.

2. **Edge caching with Amazon CloudFront** – Edge caches high-volume content to decrease the latency to customers.

3. **Edge security for Amazon CloudFront with AWS WAF** – Filters malicious traffic, including cross site scripting (XSS) and SQL injection via customer-defined rules.

4. **Load balancing with Elastic Load Balancing (ELB)** – Enables you to spread load across multiple Availability Zones and AWS Auto Scaling groups for redundancy and decoupling of services.

5. **DDoS protection with AWS Shield** – Safeguards your infrastructure against the most common network and transport layer DDoS attacks automatically.

6. **Firewalls with security groups** – Moves security to the instance to provide a stateful, host-level firewall for both web and application servers.

7. **Caching with Amazon ElastiCache** – Provides caching services with Redis or Memcached to remove load from the app and database, and lower latency for frequent requests.

8. **Managed database with Amazon Relational Database Service (Amazon RDS)** – Creates a highly available, multi-AZ database architecture with six possible DB engines.

9. **Static storage and backups with Amazon Simple Storage Service (Amazon S3)** – Enables simple HTTP-based object storage for backups and static assets like images and video.

**Architecture Design - 3 Tier Multi Region:**

<p align="center">
  <img align="center" src="image/static/AWS_Cloud_Architecture-Multi Region.png" width=100%>
</p>
<p align="center"><b>Scenario 4:</b> The Architecture Design - 3 Tier Multi Region.</p>
