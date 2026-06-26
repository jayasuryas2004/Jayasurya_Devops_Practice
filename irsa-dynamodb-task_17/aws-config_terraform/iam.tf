# 1. Define the IAM Policy for DynamoDB (Least Privilege)
data "aws_iam_policy_document" "dynamodb_access_doc" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem"
    ]
    resources = [
      var.dynamodb_table_arn
    ]
  }
}

resource "aws_iam_policy" "dynamodb_app_policy" {
  name        = "DynamoDBAppAccessPolicy"
  description = "Policy allowing Get, Put, Update on specific DynamoDB table"
  policy      = data.aws_iam_policy_document.dynamodb_access_doc.json  # ✅ Fixed
}

# 2. Define the Trust Policy (OIDC)
data "aws_iam_policy_document" "irsa_trust_doc" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# 3. Create the IAM Role
resource "aws_iam_role" "irsa_dynamodb_role" {
  name               = "IRSADynamoDBAppRole"
  assume_role_policy = data.aws_iam_policy_document.irsa_trust_doc.json  # ✅ Fixed
}

# 4. Attach the Policy to the Role
resource "aws_iam_role_policy_attachment" "irsa_policy_attach" {
  role       = aws_iam_role.irsa_dynamodb_role.name
  policy_arn = aws_iam_policy.dynamodb_app_policy.arn
}