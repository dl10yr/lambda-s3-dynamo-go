locals {
  name = "${var.project_name}-${var.env}-lambda-iam-role"
}

data "aws_iam_policy" "lambda_invocation_dynamodb" {
  arn = "arn:aws:iam::aws:policy/AWSLambdaInvocation-DynamoDB"
}

data "aws_iam_policy" "lambda_basic_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "s3_read_only_access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "dynamodb_access" {
  statement {
    actions = [
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem"
    ]
    resources = [for table in var.dynamodb_tables : "${table}*"]
  }
}


resource "aws_iam_role" "lambda_role" {
  name               = local.name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda_role.id
  policy_arn = data.aws_iam_policy.lambda_basic_execution.arn
}

resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.lambda_role.id
  policy_arn = data.aws_iam_policy.s3_read_only_access.arn
}

resource "aws_iam_role_policy_attachment" "invocation_dynamodb" {
  role       = aws_iam_role.lambda_role.id
  policy_arn = data.aws_iam_policy.lambda_invocation_dynamodb.arn
}

resource "aws_iam_role_policy" "dynamodb_access" {
  name   = "${local.name}-dynamodb-access"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.dynamodb_access.json
}
