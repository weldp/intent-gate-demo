# Intended architecture: each account keeps its own access logs.

resource "aws_s3_bucket" "prod_access_log" {
  provider = aws.prod
  bucket   = "acme-prod-access-log"
}

resource "aws_s3_bucket" "test_access_log" {
  provider = aws.test
  bucket   = "acme-test-access-log"
}

resource "aws_s3_bucket_logging" "customer_data" {
  provider      = aws.prod
  bucket        = aws_s3_bucket.customer_data.id
  target_bucket = aws_s3_bucket.prod_access_log.id
  target_prefix = "customer-data/"
}

resource "aws_s3_bucket_logging" "test_data" {
  provider      = aws.test
  bucket        = aws_s3_bucket.test_data.id
  target_bucket = aws_s3_bucket.test_access_log.id
  target_prefix = "test-data/"
}
