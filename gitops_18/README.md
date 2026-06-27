# GitOps Platform: Infrastructure & Deployment Automation

This project demonstrates a production-grade **GitOps** pipeline utilizing **Kubernetes (EKS)**, **ArgoCD**, and **Kustomize**. By adopting a "Single Source of Truth" philosophy, all infrastructure and application states are version-controlled and automatically synchronized.

## 🏗️ Architecture Overview
*   **Infrastructure as Code (IaC)**: Provisioned using **Terraform** and **Terragrunt** to ensure DRY (Don't Repeat Yourself) configurations.
*   **GitOps Engine**: **ArgoCD** facilitates automated synchronization between the GitHub repository and the EKS cluster.
*   **Configuration Management**: **Kustomize** is used for environment-specific manifest patching (`base` vs. `overlays`).
*   **Cloud Provider**: AWS EKS (Elastic Kubernetes Service).

## 🚀 Key Features
*   **Declarative Deployments**: Environment states are defined in Git; ArgoCD ensures the cluster matches the desired state.
*   **Drift Detection**: Automatic monitoring and self-healing to correct manual deviations in cluster configuration.
*   **Scalable Compute**: Integrated **Cluster Autoscaler** and **Metrics Server** for dynamic resource management.

## 🏃 How to Run This Project

1.  **Provision the Infrastructure**:
    *   Navigate to the root infrastructure directory: `cd eks-terragrunt-project_16`
    *   Initialize and apply your Terraform configuration: `terragrunt run-all apply`
    *   *For specific environment deployment:* `cd live/dev` and run `terragrunt run-all apply`.

2.  **Connect to your Cluster**:
    *   Update your local `kubectl` configuration: `aws eks update-kubeconfig --region ap-south-1 --name <your-cluster-name>`

3.  **Access ArgoCD**:
    *   Start the port-forward: `kubectl port-forward svc/argocd-server -n argocd 8080:443`
    *   Access the UI at `https://localhost:8080`.
    *   Retrieve the admin password: 
      ```powershell
      [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}")))
      ```

4.  **Deploy Applications**:
    *   Apply the application manifest from the GitOps directory to trigger the synchronization loop:
      `kubectl apply -f gitops_18/argocd-setup/dev-application.yaml`

## 🔍 Troubleshooting Common Errors

| Error | Cause | Solution |
| :--- | :--- | :--- |
| `CrashLoopBackOff` | IAM/Permission issue | Restart pod: `kubectl delete pod <pod-name> -n kube-system` |
| `Annotation Too Long` | Apply limits | Use: `kubectl apply --server-side -f <file.yaml>` |
| `Sync Status: Unknown` | Git access issues | Check: `kubectl describe application <app-name> -n argocd` |
| `kustomization.yaml is empty` | Missing content | Ensure resources are defined in `kustomization.yaml` |
| `wsarecv` (Port-forward) | HTTP/HTTPS mismatch | Use `https://localhost:8080` |

## 🔄 Reconciliation & Drift
*   **Manual Sync:** If you push a change to Git and don't want to wait for the automatic poll, click **Refresh** and **Sync** in the ArgoCD UI.
*   **Drift Detection:** If you manually delete a resource, ArgoCD will detect the discrepancy and automatically redeploy the resource to match your Git repository configuration.

## 📂 Repository Structure
```text
Jayasurya_Devops_Practice/
├── gitops_18/
│   ├── base/               # Shared Kubernetes manifests
│   ├── overlays/           # Environment-specific patches (dev, qa, prod)
│   └── argocd-setup/       # ArgoCD Application definitions
└── eks-terragrunt-project_16/  # Infrastructure provisioning code