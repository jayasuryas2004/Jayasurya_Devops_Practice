# Verify Platform
Check all Helm releases.

helm list -A

Verify AWS Load Balancer Controller.

kubectl get deployment -A | grep aws-load-balancer

Verify controller Pods.

kubectl get pods -n kube-system | grep aws-load-balancer-controller

# Verify OIDC Provider

Check the cluster OIDC issuer.

aws eks describe-cluster \
  --name devops-lab \
  --query "cluster.identity.oidc.issuer" \
  --output text

Associate IAM OIDC Provider (if required).

eksctl utils associate-iam-oidc-provider \
  --region ap-south-1 \
  --cluster devops-lab \
  --approve

# Create IAM Policy

Download the AWS Load Balancer Controller IAM policy.

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

Create IAM Policy.

aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json

If the policy already exists.

aws iam list-policies \
  --scope Local \
  --query "Policies[?PolicyName=='AWSLoadBalancerControllerIAMPolicy'].Arn" \
  --output text

 Create IRSA Service Account

Create IAM Service Account.

eksctl create iamserviceaccount \
  --cluster devops-lab \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn arn:aws:iam::<ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

Verify Service Account.

kubectl get sa aws-load-balancer-controller -n kube-system

Describe Service Account.

kubectl describe sa aws-load-balancer-controller -n kube-system

# Install AWS Load Balancer Controller

Add Helm repository.

helm repo add eks https://aws.github.io/eks-charts

Update repositories.

helm repo update

Retrieve VPC ID.

aws eks describe-cluster \
  --name devops-lab \
  --query "cluster.resourcesVpcConfig.vpcId" \
  --output text

Install controller.

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --namespace kube-system \
  --set clusterName=devops-lab \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=ap-south-1 \
  --set vpcId=<VPC_ID>

Verify installation.

helm list -A

kubectl get pods -n kube-system | grep aws-load-balancer-controller

# Create Namespace

kubectl create namespace exercise-07

Verify namespace.

kubectl get ns

# Deploy Application

Deploy NGINX.

kubectl apply -f deployment.yaml

Verify Deployment.

kubectl get deployment -n exercise-07

Verify ReplicaSet.

kubectl get rs -n exercise-07

Verify Pods.

kubectl get pods -n exercise-07

# Create ClusterIP Service

Deploy Service.

kubectl apply -f service.yaml

Verify Service.

kubectl get svc -n exercise-07

Test Service locally.

kubectl port-forward svc/web-service 8080:80 -n exercise-07

Access:

http://localhost:8080

# Create Ingress

Deploy Ingress.

kubectl apply -f ingress.yaml

Watch ALB provisioning.

kubectl get ingress -n exercise-07 -w

Describe Ingress.

kubectl describe ingress web-ingress -n exercise-07

# Verify AWS ALB

Check ALB state.

aws elbv2 describe-load-balancers \
  --query "LoadBalancers[].{Name:LoadBalancerName,DNS:DNSName,State:State.Code}" \
  --output table

Verify browser access.

http://<ALB-DNS-NAME>

Expected:

Welcome to nginx!

# Simulate Production Failure

Modify Ingress backend.

Broken configuration.

service:
  name: web-service-broken

Apply changes.

kubectl apply -f ingress.yaml

Inspect Ingress.

kubectl describe ingress web-ingress -n exercise-07

Expected:

services "web-service-broken" not found

# Investigate Failure

Describe Ingress.

kubectl describe ingress web-ingress -n exercise-07

View AWS Load Balancer Controller logs.

kubectl logs deployment/aws-load-balancer-controller \
-n kube-system --tail=100

Verify ALB state.

aws elbv2 describe-load-balancers \
  --query "LoadBalancers[].{Name:LoadBalancerName,DNS:DNSName,State:State.Code}" \
  --output table

# Restore Application

Restore the correct backend.

service:
  name: web-service

Apply configuration.

kubectl apply -f ingress.yaml

Verify Ingress.

kubectl describe ingress web-ingress -n exercise-07

Refresh browser.

Expected:

Welcome to nginx!

# Cleanup

Delete the exercise namespace.

kubectl delete namespace exercise-07

Verify namespace removal.

kubectl get ns

Verify remaining Pods.

kubectl get pods -A

Expected remaining namespaces:

    kube-system
    argocd
    external-secrets

Key Troubleshooting Commands

kubectl get ingress -n exercise-07

kubectl describe ingress web-ingress -n exercise-07

kubectl get svc -n exercise-07

kubectl get pods -n exercise-07

kubectl logs deployment/aws-load-balancer-controller -n kube-system --tail=100

aws elbv2 describe-load-balancers \
--query "LoadBalancers[].{Name:LoadBalancerName,DNS:DNSName,State:State.Code}" \
--output table

kubectl port-forward svc/web-service 8080:80 -n exercise-07