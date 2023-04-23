# Improve the availability of Operational and Regulatory Information, which inspires high levels of scalability and performance with AWS Cloud. 📲 #

The purpose of this project was to create a Web Application where all the concerned teams can find the right information related to their Operational and Regulatory Information.

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

<p align="center">
  <img align="center" src="image/static/AWS_Cloud_Architecture-Single Region.png" width=100%>
</p>
<p align="center"><b>Scenario 3:</b> The Architecture Design - 3 Tier Single Region.</p>

**Architecture Design - 3 Tier Multi Region:**

<p align="center">
  <img align="center" src="image/static/AWS_Cloud_Architecture-Multi Region.png" width=100%>
</p>
<p align="center"><b>Scenario 4:</b> The Architecture Design - 3 Tier Multi Region.</p>
