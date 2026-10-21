# Event-driven alerting: notify the engineering distribution list
# when access logs are delivered.

resource "aws_sns_topic" "access_alerts" {
  provider          = aws.test
  name              = "access-log-delivered"
  kms_master_key_id = aws_kms_key.test.arn
}

resource "aws_sns_topic_subscription" "engineering" {
  provider  = aws.test
  topic_arn = aws_sns_topic.access_alerts.arn
  protocol  = "email"
  endpoint  = "devs-mail@acme.example"
}

resource "aws_s3_bucket_notification" "access_log" {
  provider = aws.test
  bucket   = aws_s3_bucket.access_log.id
  topic {
    topic_arn = aws_sns_topic.access_alerts.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
