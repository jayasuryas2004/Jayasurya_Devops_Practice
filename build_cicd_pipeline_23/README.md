 Quick Start

Prerequisites:


GitHub account
AWS account (free tier eligible)
Docker installed locally
Git installed
AWS CLI configured


Setup Steps:

1. Clone the Repository

bashgit clone https://github.com/jayasuryas2004/Jayasurya_Devops_Practice.git
cd Jayasurya_Devops_Practice

2. Configure AWS Credentials

powershell# Configure AWS CLI
aws configure
# Enter:
# AWS Access Key ID: [your key]
# AWS Secret Access Key: [your secret]
# Default region: ap-south-1
# Default output format: json

3. Add GitHub Secrets

Go to: Settings → Secrets and variables → Actions

Add these secrets:


AWS_ACCESS_KEY_ID - Your AWS access key
AWS_SECRET_ACCESS_KEY - Your AWS secret key
GITOPS_TOKEN - Personal access token (if using custom token)


4. Create ECR Repository

powershellaws ecr create-repository \
  --repository-name build_cicd_23 \
  --region ap-south-1

# Make tags mutable (allows overwriting 'latest' tag)
aws ecr put-image-tag-mutability \
  --repository-name build_cicd_23 \
  --image-tag-mutability MUTABLE \
  --region ap-south-1

5. Update GitOps Repository

Ensure your gitops_18/base/kustomization.yaml has:

yamlapiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - services.yaml
images:
  - name: 287167053779.dkr.ecr.ap-south-1.amazonaws.com/build_cicd_23
    newTag: latest

6. Test Locally

powershell# Install dependencies
cd build_cicd_pipeline_23
pip install -r requirements.txt

# Run unit tests
python -m pytest tests/ -v

# Run security scan
bandit -r src/

# Build Docker image locally
docker build -t build_cicd_23:latest .

# Run container
docker run -p 8000:8000 build_cicd_23:latest

Visit: http://localhost:8000


📊 Pipeline Workflow

Trigger

The pipeline automatically runs when you push to main branch in paths:


build_cicd_pipeline_23/** (any change in the microservice)


Stage 1: test-and-scan (13s)

yaml✅ Checkout Code
✅ Set up Python 3.11
✅ Install Dependencies
✅ Run Unit Tests (pytest)
✅ Security Scan (Bandit)

Fails if:


Unit tests fail
Security violations detected


Stage 2: build-and-push (48s)

yaml✅ Configure AWS Credentials
✅ Login to Amazon ECR
✅ Build Docker Image
✅ Push with tags: 'latest' & commit-sha

Tags pushed:


latest - Always points to latest build
<commit-sha> - Immutable tag for this specific commit


Stage 3: gitops-update (4s)

yaml✅ Update GitOps Repository
✅ Change image tag in kustomization.yaml
✅ Commit and push to gitops_18

Updates: gitops_18/base/kustomization.yaml with new image tag

Stage 4: notify-deployment (4s)

yaml✅ Print deployment summary
✅ Show Docker image URI
✅ Show GitOps changes


🔧 How to Trigger a Pipeline Run

Method 1: Code Push

powershell# Make a change to your microservice
Add-Content build_cicd_pipeline_23/README.md "`n# Updated"

# Commit and push
git add build_cicd_pipeline_23/README.md
git commit -m "feat: update microservice"
git push origin main

# Watch it run in GitHub Actions!

Method 2: Manual Trigger (if configured)

Go to GitHub → Actions → Python Microservice CI/CD Pipeline → Run workflow


📈 Monitoring the Pipeline

GitHub Actions

Go to: https://github.com/jayasuryas2004/Jayasurya_Devops_Practice/actions

Watch:


✅ Green checkmarks = All stages passed
❌ Red X = Stage failed (see logs)
⏱️ Timing = How long each stage took


Check Deployment

powershell# Verify image in ECR
aws ecr describe-images \
  --repository-name build_cicd_23 \
  --region ap-south-1

# Check GitOps repo was updated
git -C gitops_18 log --oneline -5

ArgoCD Sync

Go to your ArgoCD UI and verify:


Application: dev-aivar-app
Status: Synced ✅
Latest image tag deployed



🐛 Troubleshooting

"Test Failed"

powershell# Run tests locally
cd build_cicd_pipeline_23
python -m pytest tests/ -v

# Fix any failing tests
# Push again to trigger pipeline

"Docker Build Failed"

powershell# Build locally to debug
docker build build_cicd_pipeline_23/

# Check Dockerfile syntax
cat build_cicd_pipeline_23/Dockerfile

"ECR Push Failed"

powershell# Check AWS credentials
aws sts get-caller-identity

# Verify ECR repository exists
aws ecr describe-repositories --region ap-south-1

# Check if tags are mutable
aws ecr describe-image-tag-mutability \
  --repository-name build_cicd_23 \
  --region ap-south-1

"GitOps Update Failed"

powershell# Verify github.token has access
# Check that gitops_18 is in same account
# Verify kustomization.yaml syntax

cat gitops_18/base/kustomization.yaml


⏸️ Pausing the Pipeline (Free Tier Cost Management)

Stop Everything Safely

powershell# 1. Disable GitHub Actions
Rename-Item .github/workflows/python-app-pipeline.yaml `
            .github/workflows/python-app-pipeline.yaml.disabled
git add .
git commit -m "chore: pause pipeline"
git push origin main

# 2. Stop EC2 instance (no compute charges)
aws ec2 describe-instances --region ap-south-1 \
  --query 'Reservations[].Instances[].[InstanceId,State.Name]' \
  --output table

aws ec2 stop-instances --instance-ids i-YOUR_INSTANCE_ID --region ap-south-1

Resume Later

powershell# 1. Re-enable workflow
Rename-Item .github/workflows/python-app-pipeline.yaml.disabled `
            .github/workflows/python-app-pipeline.yaml
git add .
git commit -m "chore: resume pipeline"
git push origin main

# 2. Start EC2 instance
aws ec2 start-instances --instance-ids i-YOUR_INSTANCE_ID --region ap-south-1

# 3. Test pipeline
Add-Content build_cicd_pipeline_23/README.md "`n# Testing"
git add .
git commit -m "test: trigger pipeline"
git push origin main