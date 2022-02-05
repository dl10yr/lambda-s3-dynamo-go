resource "aws_dynamodb_table" "members_table" {
  name         = "${var.project_name}-members-${var.env}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
