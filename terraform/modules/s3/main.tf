resource "aws_s3_bucket" "csv_import" {
  bucket = "${var.project_name}-${var.env}-csv-import"
  acl    = "private"
}

# resource "aws_lambda_permission" "allow_bucket" {
#   statement_id  = "AllowExecutionFromS3Bucket"
#   action        = "lambda:InvokeFunction"
#   function_name = ""
#   principal     = "s3.amazonaws.com"
#   source_arn    = aws_s3_bucket.csv_import.arn
# }

# resource "aws_s3_bucket_notification" "bucket_notification" {
#   bucket = aws_s3_bucket.csv_import.id

#   lambda_function {
#     lambda_function_arn = ""
#     events              = ["s3:ObjectCreated:*"]
#     filter_suffix       = ".csv"
#   }

#   depends_on = [aws_lambda_permission.allow_bucket]
# }
