# Intended architecture: prod alerts go to ops, test alerts go to developers.

resource "aws_sns_topic" "prod_alerts" {
  provider          = aws.prod
  name              = "prod-access-log-delivered"
  kms_master_key_id = aws_kms_key.prod.arn
}

resource "aws_sns_topic" "test_alerts" {
  provider          = aws.test
  name              = "test-access-log-delivered"
  kms_master_key_id = aws_kms_key.test.arn
}

resource "aws_sns_topic_subscription" "ops" {
  provider  = aws.prod
  topic_arn = aws_sns_topic.prod_alerts.arn
  protocol  = "email"
  endpoint  = "ops-mail@acme.example"
}

resource "aws_sns_topic_subscription" "devs" {
  provider  = aws.test
  topic_arn = aws_sns_topic.test_alerts.arn
  protocol  = "email"
  endpoint  = "devs-mail@acme.example"
}

resource "aws_s3_bucket_notification" "prod_access_log" {
  provider = aws.prod
  bucket   = aws_s3_bucket.prod_access_log.id
  topic {
    topic_arn = aws_sns_topic.prod_alerts.arn
    events    = ["s3:ObjectCreated:*"]
  }
}

resource "aws_s3_bucket_notification" "test_access_log" {
  provider = aws.test
  bucket   = aws_s3_bucket.test_access_log.id
  topic {
    topic_arn = aws_sns_topic.test_alerts.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
