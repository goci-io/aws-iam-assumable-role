# aws-iam-assumable-role

#### Maintained by [@goci-io/prp-terraform](https://github.com/orgs/goci-io/teams/prp-terraform)

![Terraform Validate](https://github.com/goci-io/aws-iam-assumable-role/workflows/terraform/badge.svg)

This module creates an AWS IAM Role and attaches custom policy statements and existing policies to the role. In addition to that we support generating and rotating an [External-ID](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html). 

### Usage

```hcl
module "iam_role" {
  source            = "git::https://github.com/goci-io/aws-iam-assumable-role.git?ref=tags/<latest-version>"
  namespace         = "goci"
  stage             = "corp"
  attributes        = ["eu1"]
  name              = "role"
  trusted_iam_arns  = ["arn:aws:iam::123456789012:role/allowed-to-assume"]
  policy_statements = [
    {
      actions   = ["s3:GetObject"]
      resources = ["*"]
    }
  ]
}
```

You can retrieve the role id, arn and external id via [`terraform output`](outputs.tf).


#### Attaching Policies

Policies can be attached using `policy_statements` with a basic JSON structure containing `effect`, `actions` and `resources`. 
To attach existing Policies to the Role you can provide desired Policy-ARNs using `policy_attachments`.

For full Flexibility and to serve custom Needs to you can generate your own Policy JSON using [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) Data Source.

**Example:**

```hcl
data "aws_iam_policy_document" "example" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

module "iam_role" {
  // ...
  policy_json = data.aws_iam_policy_document.example.json
}
```

_This repository was created via [github-repository](https://github.com/goci-io/github-repository)._
