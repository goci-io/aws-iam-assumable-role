module "label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.24.1"
  namespace   = var.namespace
  stage       = var.stage
  environment = var.environment
  attributes  = var.attributes
  delimiter   = var.delimiter
  tags        = var.tags
  name        = var.name
}

locals {
  iam_role_name = var.role_name_override == "" ? module.label.id : var.role_name_override
}

resource "random_uuid" "external_id" {
  count = var.enabled && var.with_external_id ? 1 : 0

  keepers = {
    rotation = var.external_id_keeper
  }
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

    dynamic "condition" {
      for_each = var.with_external_id ? [1] : []

      content {
        variable = "sts:ExternalId"
        test     = "StringEquals"
        values   = random_uuid.external_id.*.result
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

      dynamic "condition" {
        for_each = lookup(statement.value, "conditions", [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_role" "role" {
  count                 = var.enabled ? 1 : 0
  name                  = local.iam_role_name
  tags                  = module.label.tags
  force_detach_policies = var.force_detach_policies
  assume_role_policy    = data.aws_iam_policy_document.trust_relation.json
}

resource "aws_iam_role_policy" "policy" {
  count  = var.enabled && length(var.policy_statements) > 0 ? 1 : 0
  name   = module.label.id
  role   = join("", aws_iam_role.role.*.id)
  policy = data.aws_iam_policy_document.permissions.json
}

resource "aws_iam_role_policy" "custom_json_policy" {
  count  = var.enabled && var.policy_json != "" ? 1 : 0
  role   = join("", aws_iam_role.role.*.id)
  name   = format("%s%scustom", module.label.id, var.delimiter)
  policy = var.policy_json
}

resource "aws_iam_role_policy_attachment" "attachments" {
  count      = var.enabled ? length(var.policy_attachments) : 0
  role       = join("", aws_iam_role.role.*.id)
  policy_arn = element(var.policy_attachments, count.index)
}
