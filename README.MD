

# Infrastructure as Code with Terraform, AWS CLI, and kubectl

This project creates a robust cloud infrastructure on AWS using Infrastructure as Code (IaC) principles. Below is a detailed overview of what this code does, prerequisites, and how to use it.

---

## **What Does the Code Do?**

## Summary

This setup involves creating a secure and scalable VPC environment, provisioning an EKS cluster, and deploying a simple Kubernetes application (nginx) with load balancing. The configuration is highly customizable, allowing you to define network settings, scaling policies, and IAM roles, all while integrating seamlessly with AWS services.

Each environment (e.g., dev, staging, production) is defined using separate variable files.

# Overview of the Infrastructure

This infrastructure creates an Amazon Web Services (AWS) environment using Terraform to deploy and manage a VPC, an EKS (Elastic Kubernetes Service) cluster, and Kubernetes workloads.

## VPC Module

This module creates a Virtual Private Cloud (VPC) with the following components:
- **VPC Creation**: A VPC is created with a customizable CIDR block defined by the variable `vpc_cidr`.
- **Subnets**: It creates both private and public subnets within the VPC based on the provided CIDR blocks (`private_subnets`, `public_subnets`).
- **Availability Zones**: The VPC spans multiple availability zones, specified in the `azs` variable.
- **NAT Gateway**: A NAT Gateway is created for each availability zone for outbound internet access from private subnets.
- **Tags**: Tags are applied for environment categorization, with the environment tag set to the current workspace.

### Key Variables
- `vpc_name`: The name of the VPC.
- `vpc_cidr`: The CIDR block for the VPC.
- `azs`: Availability zones for the VPC.
- `private_subnets`: CIDR blocks for private subnets.
- `public_subnets`: CIDR blocks for public subnets.

## EKS Module

The EKS module configures an Amazon Elastic Kubernetes Service (EKS) cluster with the following features:
- **EKS Cluster**: Creates an EKS cluster with a specified version and name, and exposes the cluster endpoint publicly.
- **IAM Role Creation**: It creates an IAM role for the cluster, which includes administrative permissions for the cluster creator.
- **Addons**: Installs necessary EKS addons such as CoreDNS, VPC CNI, Kube Proxy, and the EKS Pod Identity Agent.
- **Managed Node Groups**: A managed node group for worker nodes is created, where instance types, AMI, and desired capacity can be configured.
- **Tags**: Tags for organizing the cluster, similar to the VPC module.

### Key Variables
- `cluster_name`: The name of the EKS cluster.
- `cluster_version`: The version of the EKS cluster.
- `vpc_id`: The VPC ID where the EKS cluster is deployed.
- `worker_subnet_ids`: The subnet IDs for worker nodes in the EKS cluster.
- `control_plane_subnet_ids`: The subnet IDs for the control plane.

## Kubernetes (K8s) Module

This module sets up Kubernetes resources including IAM roles and services within the EKS cluster:
- **IAM Policy and Role**: Creates a custom IAM policy and role for the AWS Load Balancer Controller to manage load balancers and other resources.
- **ServiceAccount**: A Kubernetes ServiceAccount is created for the AWS Load Balancer Controller.
- **Load Balancer Controller Installation**: Using Helm, it installs the AWS Load Balancer Controller in the Kubernetes cluster to manage AWS resources like load balancers.
- **Kubernetes Deployment**: A simple web application (nginx) is deployed in the Kubernetes cluster using a `Deployment` resource.
- **Kubernetes Service**: A `LoadBalancer` service is created to expose the nginx web application externally.

### Key Variables
- `cluster_name`: The name of the Kubernetes cluster.
- `cluster_endpoint`: The endpoint URL for the EKS cluster.
- `cluster_certificate_authority_data`: The certificate authority data for the EKS cluster.



### **Example Configuration Parameters (Environment-Specific):**
```hcl
#vpc variables
vpc_name       = "duplocloud-dev-vpc"
vpc_cidr       = "10.0.0.0/16"
azs            = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]


#eks variables
cluster_name    = "dev-cluster"
cluster_version = "1.31" #kubernetes version
eks_managed_ng_instance_types = ["t3.small", "t2.small"]
eks_managed_ng_optimized_ami = "AL2023_x86_64_STANDARD" #mazon Linux 2023 (AL2023) for the x86_64 architecture. Since EKS 1.30, AL2023 is the default AMI.
eks_managed_ng_min_size = 2 #Should be 2 for requirements of CoreDNS addons
eks_managed_ng_max_size = 3
eks_managed_ng_desire_size = 2
```

---

# Project Structure for Terraform

This document outlines the structure of the Terraform project and explains the purpose of each directory and file.

## **Directory Structure**

```
TERRAFORM
├── environments/
│   ├── dev/
│   │   └── terraform.tfvars
│   ├── prod/
│   │   └── terraform.tfvars
│   └── staging/
│       └── terraform.tfvars
├── modules/
│   ├── eks/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── k8s/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── vpc/
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── terraform.tfstate.d/
├── main.tf
├── outputs.tf
├── provider.tf
├── README.MD
└── variables.tf
```

## **Description of Files and Folders**

### **environments/**
- **Purpose:**
  - Contains environment-specific configuration files to manage resources in different stages (e.g., development, staging, production).
- **Subdirectories:**
  - **dev/**: Stores `terraform.tfvars` for development-specific configurations.
  - **prod/**: Stores `terraform.tfvars` for production-specific configurations.
  - **staging/**: Stores `terraform.tfvars` for staging-specific configurations.
- **Why this structure?**
  - It helps segregate environment-specific configurations, making it easier to manage and deploy resources independently.

---

### **modules/**
- **Purpose:**
  - Contains reusable Terraform modules for different components of the infrastructure.
- **Submodules:**
  - **eks/**: Manages resources related to Amazon Elastic Kubernetes Service (EKS).
    - **main.tf:** Core configuration for EKS.
    - **outputs.tf:** Outputs for EKS resources.
    - **variables.tf:** Input variables for EKS configuration.
  - **k8s/**: Manages Kubernetes-related resources.
    - Similar structure to EKS with `main.tf`, `outputs.tf`, and `variables.tf` files.
  - **vpc/**: Manages resources for the Virtual Private Cloud (VPC).
    - Includes configurations, outputs, and variables for VPC setup.
- **Why this structure?**
  - Modularizing components promotes reusability and maintainability.

---

### **terraform.tfstate.d/**
- **Purpose:**
  - Stores Terraform state files in a structured manner.
  - Useful for managing remote state and locking for multi-user environments.
- **Why this structure?**
  - It provides a clean separation for state files, ensuring they don't clutter the root directory.

---

### **Root-Level Files**
- **main.tf:**
  - The primary entry point for defining resources and invoking modules.
- **outputs.tf:**
  - Defines outputs for the entire project.
- **provider.tf:**
  - This configuration file sets up the necessary providers and authentication to manage AWS, Kubernetes, and Helm resources in the context of deploying an EKS (Elastic Kubernetes Service) cluster. It defines the required provider versions and configures authentication for seamless integration.
- **terraform.tfvars:**
  - Contains default variable values for the project.
- **variables.tf:**
  - Defines variables that can be used throughout the project.
- **README.MD:**
  - Documentation for understanding the project structure and purpose.

---

## **Best Practices Followed**
1. **Environment Separation:**
   - Isolating configurations for development, staging, and production ensures safe deployments.
2. **Modularization:**
   - Modules promote reusability and reduce duplication of configurations.
3. **State Management:**
   - Using `terraform.tfstate.d/` for managing state files provides better organization.
4. **Dependency Locking:**
   - `.terraform.lock.hcl` ensures consistent provider versions across environments.

---

This structure is designed to be scalable, maintainable, and secure, adhering to Terraform best practices for infrastructure as code (IaC).

----


# Provider.tf: Configuration for Terraform, AWS, Kubernetes, and Helm Providers

This configuration file sets up the necessary providers and authentication to manage AWS, Kubernetes, and Helm resources in the context of deploying an EKS (Elastic Kubernetes Service) cluster. It defines the required provider versions and configures authentication for seamless integration.

## Terraform Block

The `terraform` block specifies the required version of Terraform and the necessary providers:

- **Required Version**: Terraform version `>= 1.3.3` is required.
- **Required Providers**:
  - **AWS**: Uses the `hashicorp/aws` provider (version `~> 5.0`) to manage AWS services.
  - **Kubernetes**: Uses the `hashicorp/kubernetes` provider (version `~> 2.20`) to interact with Kubernetes resources.
  - **Helm**: Uses the `hashicorp/helm` provider (version `~> 2.6`) for managing Helm charts in the Kubernetes cluster.

## AWS Provider

The `aws` provider configures access to AWS services:

- **Region**: The AWS region is set using the `aws_region` variable, which should be defined elsewhere in the Terraform configuration.

### Key Variable
- `aws_region`: The AWS region where resources are managed.

## Kubernetes Provider

The `kubernetes` provider is used to authenticate and manage Kubernetes resources in the EKS cluster:

- **Host**: The `host` value is set to the `cluster_endpoint` of the EKS cluster, provided by the EKS module.
- **Cluster Certificate Authority**: The cluster's certificate authority is decoded from base64 for secure communication with the Kubernetes API.
- **Token**: The authentication token is retrieved from the `aws_eks_cluster_auth` data source to authenticate the session.

## Helm Provider

The `helm` provider is used for managing Helm charts within the Kubernetes cluster:

- The `helm` provider uses the same configuration as the Kubernetes provider to authenticate with the cluster.

## EKS Cluster Authentication Data

The `aws_eks_cluster_auth` data source retrieves the authentication token needed to access the EKS cluster:

- **Cluster Name**: The cluster name is provided by the EKS module to authenticate access to the Kubernetes API.

### Key Resource
- `aws_eks_cluster_auth`: Retrieves the authentication token used to interact with the EKS cluster.

## Summary

This configuration sets up the required providers to manage AWS, Kubernetes, and Helm resources. It ensures Terraform can authenticate and manage infrastructure in AWS (for EKS) and Kubernetes (for workloads), enabling smooth operations and provisioning.

By using the authentication token and certificate, secure communication between Terraform and the cloud services is ensured. This setup simplifies the management of both infrastructure and Kubernetes workloads in a cloud-native environment.


---

## **Prerequisites**

### **1. Tools**
- **AWS CLI**: To interact with AWS services.
- **Terraform**: For deploying infrastructure as code.
- **kubectl**: To manage Kubernetes resources after deploying the EKS cluster.

### **2. AWS IAM User**
- Create an IAM user with `AdministratorAccess` for this project.
- Follow the principle of least privilege and limit permissions in production environments.

### ⚠️ Note
The use of an IAM user with `AdministratorAccess` should be strictly limited to testing or initial project setup. 

In production environments, it is essential to follow the **Principle of Least Privilege** to minimize security risks, granting only the permissions necessary to perform specific tasks.


### **3. macOS System**
- These instructions assume you're using a macOS environment.

---

## **Setup Instructions**

### **Step 1: Install Required Tools**

#### **1.1 Install AWS CLI**
```bash
brew install awscli
aws --version
aws configure
```

#### **1.2 Install Terraform**
```bash
brew install terraform
terraform version
```

#### **1.3 Install kubectl**
```bash
brew install kubectl
kubectl version --client
```

---

### **Step 2: Initialize and Configure Terraform**

#### **2.1 Initialize Terraform**
```bash
terraform init
```

#### **2.2 Create Terraform Workspaces**
Workspaces allow managing separate environments (e.g., dev, staging, production) within the same project.

```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new production
```

#### **2.3 Switch Between Workspaces**
```bash
terraform workspace select dev
```

---

### **Step 3: Deploy the Infrastructure**

#### **3.1 Define Environment-Specific Variables**
Create separate `.tfvars` files for each environment, for example:

**`environments/dev/terraform.tfvars`**:
```hcl
#vpc variables
vpc_name       = "duplocloud-dev-vpc"
vpc_cidr       = "10.0.0.0/16"
azs            = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]


#eks variables
cluster_name    = "dev-cluster"
cluster_version = "1.31" #kubernetes version
eks_managed_ng_instance_types = ["t3.small", "t2.small"]
eks_managed_ng_optimized_ami = "AL2023_x86_64_STANDARD" #mazon Linux 2023 (AL2023) for the x86_64 architecture. Since EKS 1.30, AL2023 is the default AMI.
eks_managed_ng_min_size = 2 #Should be 2 for requirements of CoreDNS addons
eks_managed_ng_max_size = 3
eks_managed_ng_desire_size = 2
```

This file contains the Terraform variable definitions used to configure the Virtual Private Cloud (VPC) and Elastic Kubernetes Service (EKS) cluster. Below is a detailed explanation of each variable.

##### VPC Variables

These variables are used to configure the VPC, including CIDR block, availability zones, and subnet definitions.

##### `vpc_name`
- **Type**: String
- **Description**: The name assigned to the VPC.
- **Value**: `"duplocloud-dev-vpc"`

##### `vpc_cidr`
- **Type**: String
- **Description**: The CIDR block for the VPC network.
- **Value**: `"10.0.0.0/16"`

##### `azs`
- **Type**: List of Strings
- **Description**: A list of Availability Zones (AZs) to deploy resources across.
- **Value**: `["us-east-1a", "us-east-1b", "us-east-1c"]`

##### `public_subnets`
- **Type**: List of Strings
- **Description**: A list of CIDR blocks for public subnets in the VPC. These subnets will be accessible from the internet.
- **Value**: `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]`

##### `private_subnets`
- **Type**: List of Strings
- **Description**: A list of CIDR blocks for private subnets in the VPC. These subnets will not be directly accessible from the internet.
- **Value**: `["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]`

##### EKS Variables

These variables configure the EKS cluster, including the cluster's name, Kubernetes version, and managed node group settings.

##### `cluster_name`
- **Type**: String
- **Description**: The name of the EKS cluster.
- **Value**: `"dev-cluster"`

##### `cluster_version`
- **Type**: String
- **Description**: The version of Kubernetes to be used by the EKS cluster.
- **Value**: `"1.31"`

##### `eks_managed_ng_instance_types`
- **Type**: List of Strings
- **Description**: A list of instance types for the managed node groups in the EKS cluster.
- **Value**: `["t3.small", "t2.small"]`

##### `eks_managed_ng_optimized_ami`
- **Type**: String
- **Description**: The Amazon Machine Image (AMI) to be used by the managed node groups. The specified AMI is Amazon Linux 2023 (AL2023), the default AMI for EKS 1.30 and later.
- **Value**: `"AL2023_x86_64_STANDARD"`

##### `eks_managed_ng_min_size`
- **Type**: Integer
- **Description**: The minimum number of instances for the managed node group. A minimum of 2 is required for the CoreDNS addon.
- **Value**: `2`

##### `eks_managed_ng_max_size`
- **Type**: Integer
- **Description**: The maximum number of instances for the managed node group.
- **Value**: `3`

##### `eks_managed_ng_desire_size`
- **Type**: Integer
- **Description**: The desired number of instances for the managed node group.
- **Value**: `2`



#### **3.2 Apply Terraform for a Specific Environment**
Switch to the appropriate workspace and apply the configuration:
```bash
terraform workspace select dev
terraform apply -var-file="environments/dev/terraform.tfvars"
```

#### **3.3 Manage Other Environments**
For staging or production, repeat the process using the respective `.tfvars` files:
```bash
terraform workspace select staging
terraform apply -var-file="environments/staging/terraform.tfvars"
```

#### **3.4 Destroy Resources**
To remove resources from an environment:
```bash
terraform workspace select dev
terraform destroy -var-file="environments/dev/terraform.tfvars"
```

---

### **Step 4: Configure kubectl to Access the Cluster**

Once the infrastructure is deployed, configure `kubectl` to interact with the EKS cluster.

#### **4.1 Update kubeconfig**
Run the following AWS CLI command to update the kubeconfig file with your EKS cluster details:
```bash
aws eks --region <aws-region> update-kubeconfig --name <cluster-name>
```

#### **4.2 Verify Cluster Access**
Verify that `kubectl` can interact with the cluster:
```bash
kubectl get nodes
```

#### **4.3 Deploy Kubernetes Resources**
Deploy your workloads or Kubernetes resources:
```bash
kubectl apply -f <resource-file.yaml>
```

#### **4.4 Best Practices**
- Use namespaces to organize resources for different environments.
- Apply role-based access control (RBAC) for managing access.

---

### **Best Practices for IAM and Kubernetes RBAC**

#### **1. IAM Best Practices**
- Use the **principle of least privilege**: Grant users only the permissions they need.
- Enable **MFA** for added security.
- Use **IAM roles** for applications instead of long-term access keys.

#### **2. Kubernetes RBAC Best Practices**
- Define roles with limited permissions.
- Use namespaces to isolate resources.
- Bind roles to specific users or service accounts.

---

