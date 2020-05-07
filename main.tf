terraform {
  required_version = ">= 0.12.1"

  required_providers {
    aws    = "~> 2.50"
    random = "~> 2.2"
  }
}

module "label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  namespace   = var.namespace
  stage       = var.stage
  environment = var.environment
  attributes  = var.attributes
  delimiter   = var.delimiter
  tags        = var.tags
}

data "aws_iam_policy_document" "trust_relation" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    dynamic "principals" {
      for_each = length(var.trusted_iam_arns) > 0 ? [1] : []

      content {
        type        = "AWS"
        identifiers = var.trusted_iam_arns
      }
    }

    dynamic "principals" {
      for_each = length(var.trusted_services) > 0 ? [1] : []

      content {
        type        = "Service"
        identifiers = var.trusted_services
      }
    }
  }
}

data "aws_iam_policy_document" "permissions" {
  dynamic "statement" {
    for_each = var.policy_statements

    content {
      effect    = lookup(statement.value, "effect", "Allow")
      actions   = lookup(statement.value, "actions")
      resources = lookup(statement.value, "resources")
    }
  }
}

resource "aws_iam_role" "role" {
  count              = var.enabled ? 1 : 0
  name               = module.label.id
  tags               = module.label.tags
  assume_role_policy = data.aws_iam_policy_document.trust_relation.json
}

resource "aws_iam_role_policy" "policy" {
  count  = var.enabled ? 1 : 0
  name   = module.label.id
  role   = join("", aws_iam_role.role.*.id)
  policy = data.aws_iam_policy_document.permissions.json
}

resource "aws_iam_role_policy_attachment" "attachments" {
  count      = var.enabled ? length(var.policy_attachments) : 0
  role       = join("", aws_iam_role.role.*.id)
  policy_arn = element(var.policy_attachments, count.index)
}
