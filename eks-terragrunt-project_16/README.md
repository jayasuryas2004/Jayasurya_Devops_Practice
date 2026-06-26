# Project: EKS Infrastructure with Terragrunt (Task 16)

## Overview
This repository contains the infrastructure configuration for an AWS EKS cluster, managed using **Terragrunt** and **Terraform**. 

## Task 16: Cluster Autoscaler Implementation
This module deploys the Kubernetes Cluster Autoscaler to enable dynamic scaling of worker nodes based on pending workload demands.

### Technical Challenges Encountered
1. **Authentication Failure (403 AccessDenied)**
   - **Error:** `sts:AssumeRoleWithWebIdentity` - `403 AccessDenied`
   - **Root Cause:** A mismatch between the IAM OIDC Provider thumbprint in AWS and the standard EKS requirement, combined with an incorrect ServiceAccount name in the IAM Role Trust Policy.
   - **Resolution:** - Updated IAM OIDC Provider thumbprint to: `9e99a48a9960b14926bb7f3b02e22da2b0ab7280`.
     - Updated Trust Relationship JSON to map: `system:serviceaccount:kube-system:cluster-autoscaler-aws-cluster-autoscaler`.

2. **API Discovery Warnings**
   - **Error:** `Failed to watch ... the server could not find the requested resource`
   - **Resolution:** Identified as informational warnings caused by the Autoscaler attempting to poll newer K8s APIs (e.g., `DeviceClass`) not present in the current cluster version. Safely ignored as authentication is confirmed.

## How to Deploy & Run
To deploy these changes to your AWS environment, use the following commands from the root directory:

1. **Plan infrastructure changes:**
   ```powershell
   terragrunt run-all plan

    Apply infrastructure changes:
    PowerShell

    terragrunt run-all apply

    Verify the Autoscaler status:
    PowerShell

    kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-cluster-autoscaler

Verification

    Pod Status: Verified cluster-autoscaler is Running (1/1) with zero restarts.

    Node Scaling: Verified that the autoscaler is actively monitoring the ASG tags:

        k8s.io/cluster-autoscaler/enabled=true

        k8s.io/cluster-autoscaler/dev-eks-cluster=owned

Project Structure
Plaintext

eks-terragrunt-project_16/
├── README.md             # Project documentation
├── live/                 # Terragrunt live configurations
│   └── dev/
│       └── eks-addons/   # Autoscaler module
├── screenshots/          # Evidence of success
└── modules/              # Terraform modules


---

### 2. Required Screenshots (The Proof)
Create a folder named `screenshots` in your root directory. Capture these three views:

1.  **`pod-status.png`**: Run `kubectl get pods -n kube-system` and capture the line showing the `cluster-autoscaler` is `Running`.
2.  **`root-folder-view.png`**: Open VS Code, expand your file tree to show the `live`, `modules`, `screenshots`, and `README.md` files clearly.

---

### 3. Understanding the Architecture
To help you explain this to your mentor, remember that you configured **IRSA (IAM Roles for Service Accounts)**.



The flow you built works like this:
1. **Kubernetes** provides a token to the pod.
2. **The Pod** sends this token to **AWS STS**.
3. **AWS STS** checks the **IAM Identity Provider** (your OIDC URL + thumbprint) to see if the token is valid.
4. **AWS STS** verifies the **Trust Policy Condition** (the specific ServiceAccount name) to see if that pod is allowed to "assume the role."
5. **AWS** grants the Pod temporary credentials to manage the **Auto Scaling Group**.

By fixing the thumbprint and the ServiceAccount name, you closed the loop on this security handshake.