# 1. PROVIDERS
provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", "us-east-1"]
  }
}

provider "helm" {
  repository_config_path = "${path.module}/repositories.yaml"
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", "us-east-1"]
    }
  }
}

# 2. HELM REPO CONFIG FILE
resource "local_file" "helm_repo_config" {
  filename = "${path.module}/repositories.yaml"
  content  = "apiVersion: v1\nrepositories: []\n"
}

# 3. NAMESPACE
resource "kubernetes_namespace_v1" "env_namespace" {
  metadata {
    name = var.env
  }
}

# 4. METRICS SERVER
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  verify     = false

  values = [
    <<EOF
args:
  - --kubelet-insecure-tls
EOF
  ]
}

# 5. CLUSTER AUTOSCALER
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  verify     = false

  values = [
    <<EOF
autoDiscovery:
  clusterName: ${var.cluster_name}
rbac:
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: ${aws_iam_role.cluster_autoscaler.arn}
EOF
  ]
}

# 6. IAM ROLE FOR CLUSTER AUTOSCALER
data "aws_iam_policy_document" "autoscaler_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      # This dynamically generates the exact string your policy requires
      variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }
  }
}

resource "aws_iam_role" "cluster_autoscaler" {
  name               = "${var.cluster_name}-cluster-autoscaler"
  assume_role_policy = data.aws_iam_policy_document.autoscaler_assume_role.json
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}