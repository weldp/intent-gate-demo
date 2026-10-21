# Data buckets. One per account. Not changed by the agent.

resource "aws_s3_bucket" "customer_data" {
  provider = aws.prod
  bucket   = "acme-customer-data"
}

resource "aws_s3_bucket" "test_data" {
  provider = aws.test
  bucket   = "acme-test-data"
}
