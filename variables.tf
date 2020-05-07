variable "namespace" {
  type        = string
  default     = ""
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'goci' or 'cp'"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT'"
}

variable "stage" {
  type        = string
  default     = ""
  description = "Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'"
}

variable "name" {
  type        = string
  default     = ""
  description = "Solution name, e.g. 'app' or 'jenkins'"
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}

variable "with_external_id" {
  type        = bool
  default     = true
  description = "Creates a random UUID as external ID and attaches an additional condition to the TrustRelation policy"
}

variable "external_id_rotation" {
  type        = string
  default     = "initial"
  description = "Changes to this value lead to a new external id (pipeline must run)."
}

variable "trusted_iam_arns" {
  type        = list(string)
  default     = []
  description = "IAM ARNs to allow sts:AssumeRole on the created role. For eample an IAM or Account ARN"
}

variable "trusted_services" {
  type        = list(string)
  default     = []
  description = "Additional trusted AWS services like ec2.amazonaws.com to be allowed to assume the role"
}

variable "policy_attachments" {
  type        = list(string)
  default     = []
  description = "Additional existing policy ARNs to attach to the role"
}

variable "policy_statements" {
  type        = list(any)
  default     = []
  description = "Policy attachments in Terraform style (effect, actions, resources)"
}
