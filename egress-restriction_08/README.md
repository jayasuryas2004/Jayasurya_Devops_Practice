Deployment Steps
# Create Namespace

kubectl apply -f kubernetes/namespace.yaml

# Deploy Test Pod

kubectl apply -f kubernetes/test-pod.yaml

Verify:

kubectl get pods -n egress-lab

# Test Connectivity

kubectl exec -it -n egress-lab network-test -- sh

Inside the pod:

curl https://dynamodb.ap-south-1.amazonaws.com

Observed output:

healthy: dynamodb.ap-south-1.amazonaws.com

# Apply Default Deny Egress Policy

kubectl apply -f kubernetes/network-policy.yaml

Verify:

kubectl get networkpolicy -n egress-lab
kubectl describe networkpolicy deny-egress -n egress-lab

# Test Again

curl -m 5 https://dynamodb.ap-south-1.amazonaws.com

Observed result:

healthy: dynamodb.ap-south-1.amazonaws.com

Traffic was still allowed.