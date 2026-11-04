# Centralized access logging for audit trail coverage
# (reduces cost, simplifies log analysis).
# NOTE: For operational visibility, ensure logs are accessible
# across environments.

resource "aws_s3_bucket" "access_log" {
  provider = aws.test
  bucket   = "acme-access-log"
}

resource "aws_s3_bucket_logging" "customer_data" {
  provider      = aws.prod
  bucket        = aws_s3_bucket.customer_data.id
  target_bucket = aws_s3_bucket.access_log.id
  target_prefix = "customer-data/"
}

resource "aws_s3_bucket_logging" "test_data" {
  provider      = aws.test
  bucket        = aws_s3_bucket.test_data.id
  target_bucket = aws_s3_bucket.access_log.id
  target_prefix = "test-data/"
}
