locals {

  # Existing IAM role ARN
  existing_iam_role_arn = var.iam_role_arn != null ? var.iam_role_arn : aws_iam_role.rds_proxy[0].arn

  # Create new IAM role and policy names if not provided by the caller.
  iam_role_name   = var.iam_role_name != null ? var.iam_role_name : "${var.name}-rds-proxy-role"
  iam_policy_name = var.iam_policy_name != null ? var.iam_policy_name : "${var.name}-rds-proxy-policy"

  # Collect all secret ARNs from the auth map for the IAM policy.
  secret_arns = [for auth in values(var.auth) : auth.secret_arn]
}

# --------------------- 
# IAM Role and Policy #
# ---------------------

data "aws_iam_policy_document" "assume_role" {
  count = var.iam_role_arn == null ? 1 : 0

  statement {
    sid     = "AllowRDSProxyAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_proxy" {
  count = var.iam_role_arn == null ? 1 : 0

  name                 = local.iam_role_name
  path                 = var.iam_role_path
  permissions_boundary = var.iam_role_permissions_boundary
  assume_role_policy   = data.aws_iam_policy_document.assume_role[0].json

  tags = var.tags
}

data "aws_iam_policy_document" "proxy_access" {
  count = var.iam_role_arn == null ? 1 : 0

  # Allow the proxy to retrieve the DB secrets.
  statement {
    sid = "AllowGetSecretValue"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = local.secret_arns
  }

  # Allow decryption using specified KMS keys (optional).
  dynamic "statement" {
    for_each = length(var.kms_key_arns) > 0 ? [1] : []
    content {
      sid = "AllowKMSDecrypt"
      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKey",
      ]
      resources = var.kms_key_arns
    }
  }
}

resource "aws_iam_role_policy" "proxy_access" {
  count = var.iam_role_arn == null ? 1 : 0

  name   = local.iam_policy_name
  role   = aws_iam_role.rds_proxy[0].id
  policy = data.aws_iam_policy_document.proxy_access[0].json
}
