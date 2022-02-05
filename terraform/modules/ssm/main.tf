resource "aws_ssm_parameter" "role_arn" {
  name  = "/${var.project_name}/${var.env}/role_arn"
  type  = "String"
  value = var.role_arn
}
