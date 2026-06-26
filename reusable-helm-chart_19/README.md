# Reusable Microservice Helm Chart

A highly reusable, environment-aware Helm chart for deploying standard microservices with built-in support for autoscaling, dynamic secrets, and environment parity.

## Features Supported
* Dynamic Replicas & Resource Limits
* Auto-encoded Base64 Secrets & Plaintext ConfigMaps
* Environment-toggled Ingress Routing
* Environment-toggled Horizontal Pod Autoscaler (HPA)

## Environments Setup

This chart uses environment-specific override files to maintain parity while optimizing costs.

### 1. Development (Local/Cheap)
Deploys a single lightweight pod with mock secrets. Autoscaling and Ingress are disabled.
`helm upgrade --install my-app . -f values-dev.yaml`

### 2. QA (Testing)
Deploys 2 pods with medium resources and exposes the application via a QA Ingress URL.
`helm upgrade --install my-app . -f values-qa.yaml`

### 3. Production (High Availability)
Deploys a minimum of 3 pods with strict resource limits, production URLs, and HPA enabled to scale up to 10 pods during traffic spikes.
`helm upgrade --install my-app . -f values-prod.yaml`