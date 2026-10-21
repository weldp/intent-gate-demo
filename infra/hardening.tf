# Generic hardening that scanners check for. Not part of the boundary story.

# --- customer_data ---
resource "aws_s3_bucket_versioning" "customer_data" {
  provider = aws.prod
  bucket   = aws_s3_bucket.customer_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "customer_data" {
  provider = aws.prod
  bucket   = aws_s3_bucket.customer_data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.prod.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "customer_data" {
  provider                = aws.prod
  bucket                  = aws_s3_bucket.customer_data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "customer_data" {
  provider = aws.prod
  bucket   = aws_s3_bucket.customer_data.id
  rule {
    id     = "retention"
    status = "Enabled"
    filter {}
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_notification" "customer_data" {
  provider    = aws.prod
  bucket      = aws_s3_bucket.customer_data.id
  eventbridge = true
}

# --- test_data ---
resource "aws_s3_bucket_versioning" "test_data" {
  provider = aws.test
  bucket   = aws_s3_bucket.test_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "test_data" {
  provider = aws.test
  bucket   = aws_s3_bucket.test_data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.test.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "test_data" {
  provider                = aws.test
  bucket                  = aws_s3_bucket.test_data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "test_data" {
  provider = aws.test
  bucket   = aws_s3_bucket.test_data.id
  rule {
    id     = "retention"
    status = "Enabled"
    filter {}
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_notification" "test_data" {
  provider    = aws.test
  bucket      = aws_s3_bucket.test_data.id
  eventbridge = true
}

# --- prod_access_log ---
resource "aws_s3_bucket_versioning" "prod_access_log" {
  provider = aws.prod
  bucket   = aws_s3_bucket.prod_access_log.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "prod_access_log" {
  provider = aws.prod
  bucket   = aws_s3_bucket.prod_access_log.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.prod.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "prod_access_log" {
  provider                = aws.prod
  bucket                  = aws_s3_bucket.prod_access_log.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "prod_access_log" {
  provider = aws.prod
  bucket   = aws_s3_bucket.prod_access_log.id
  rule {
    id     = "retention"
    status = "Enabled"
    filter {}
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# --- test_access_log ---
resource "aws_s3_bucket_versioning" "test_access_log" {
  provider = aws.test
  bucket   = aws_s3_bucket.test_access_log.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "test_access_log" {
  provider = aws.test
  bucket   = aws_s3_bucket.test_access_log.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.test.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "test_access_log" {
  provider                = aws.test
  bucket                  = aws_s3_bucket.test_access_log.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "test_access_log" {
  provider = aws.test
  bucket   = aws_s3_bucket.test_access_log.id
  rule {
    id     = "retention"
    status = "Enabled"
    filter {}
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
