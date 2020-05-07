output "role_id" {
  value = join("", aws_iam_role.role.*.id)
}

output "role_arn" {
  value = join("", aws_iam_role.role.*.arn)
}
