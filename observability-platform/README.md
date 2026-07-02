# Install Prometheus + Grafana

Added Helm Repo:

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

Installed Stack:

helm install monitoring prometheus-community/kube-prometheus-stack \
-n monitoring \
--create-namespace

# Centralized Logging
Problem

Each pod stores logs independently.

Checking logs manually:

kubectl logs <pod-name>

becomes difficult as pods scale.
Why Loki?

Loki stores logs efficiently and integrates with Grafana.
Loki Installation

Added repo:

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

Installed:

helm install loki grafana/loki \
-n logging \
--create-namespace

Verify:

kubectl get pods -n logging

Alloy
Why Alloy?

Alloy collects logs from Kubernetes and forwards them to Loki.

Installed:

helm install alloy grafana/alloy \
-n logging

Verification

Check logs:

kubectl logs -n logging daemonset/alloy

Grafana + Loki Integration

Datasource:

Loki

Query Example:

{job="loki.source.kubernetes.pods"}

Filtered Payment Service Logs:

{instance="observability/payment-service-xxxxx:payment-service"}

Observed:

GET /metrics HTTP/1.1 200

This proved centralized logging was working.
Phase 4: Metrics Server
Why?

HPA requires CPU and memory metrics.

Install:

minikube addons enable metrics-server

Verify:

kubectl top nodes
kubectl top pods -n observability

Phase 5: Horizontal Pod Autoscaler (HPA)
Why?

Automatically scales pods based on resource usage.

Without HPA:

Traffic ↑
Pods stay same
Application may become slow

With HPA:

Traffic ↑
CPU ↑
Pods ↑

Resource Requests and Limits

Added:

resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "256Mi"

Reason:

HPA calculates utilization based on requested resources.
Create HPA

kubectl autoscale deployment payment-service \
--cpu-percent=50 \
--min=2 \
--max=6 \
-n observability

Verify:

kubectl get hpa -n observability

Result:

cpu: 1%/50%

This confirmed HPA was receiving metrics correctly.
Commands Frequently Used

View Pods:

kubectl get pods -A

Watch Pods:

kubectl get pods -w

Describe Resource:

kubectl describe <resource>

View Logs:

kubectl logs <pod-name>

Port Forward:

kubectl port-forward svc/<service> local:target

Metrics:

kubectl top pods
kubectl top nodes