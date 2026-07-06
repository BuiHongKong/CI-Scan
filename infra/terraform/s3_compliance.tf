data "aws_iam_policy_document" "kms_key" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow S3 service to use the key"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]

    resources = ["*"]
  }
}

resource "aws_kms_key_policy" "app_data" {
  key_id = aws_kms_key.app_data.id
  policy = data.aws_iam_policy_document.kms_key.json
}

resource "aws_sns_topic" "s3_events" {
  name              = "${var.project_name}-${var.environment}-s3-events"
  kms_master_key_id = aws_kms_key.app_data.arn
}

data "aws_iam_policy_document" "sns_s3_publish" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.s3_events.arn]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        aws_s3_bucket.logs.arn,
        aws_s3_bucket.app_data.arn,
      ]
    }
  }
}

resource "aws_sns_topic_policy" "s3_events" {
  arn    = aws_sns_topic.s3_events.arn
  policy = data.aws_iam_policy_document.sns_s3_publish.json
}

resource "aws_s3_bucket_notification" "logs" {
  bucket = aws_s3_bucket.logs.id

  topic {
    topic_arn = aws_sns_topic.s3_events.arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_sns_topic_policy.s3_events]
}

resource "aws_s3_bucket_notification" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  topic {
    topic_arn = aws_sns_topic.s3_events.arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_sns_topic_policy.s3_events]
}

data "aws_iam_policy_document" "s3_replication_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "s3_replication" {
  name               = "${var.project_name}-${var.environment}-s3-replication"
  assume_role_policy = data.aws_iam_policy_document.s3_replication_assume_role.json
}

data "aws_iam_policy_document" "s3_replication" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.logs.arn,
      aws_s3_bucket.app_data.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]
    resources = [
      "${aws_s3_bucket.logs.arn}/*",
      "${aws_s3_bucket.app_data.arn}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]
    resources = [
      "${aws_s3_bucket.logs_replica.arn}/*",
      "${aws_s3_bucket.app_data_replica.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "s3_replication" {
  name   = "${var.project_name}-s3-replication"
  role   = aws_iam_role.s3_replication.id
  policy = data.aws_iam_policy_document.s3_replication.json
}

resource "aws_s3_bucket" "logs_replica" {
  provider = aws.replica
  bucket   = "${var.project_name}-${var.environment}-logs-replica-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.project_name}-logs-replica"
  }
}

resource "aws_s3_bucket_versioning" "logs_replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.logs_replica.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "logs_replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.logs_replica.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "app_data_replica" {
  provider = aws.replica
  bucket   = "${var.project_name}-${var.environment}-data-replica-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.project_name}-data-replica"
  }
}

resource "aws_s3_bucket_versioning" "app_data_replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.app_data_replica.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "app_data_replica" {
  provider = aws.replica
  bucket   = aws_s3_bucket.app_data_replica.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_replication_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  role   = aws_iam_role.s3_replication.arn

  rule {
    id     = "replicate-logs-cross-region"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.logs_replica.arn
      storage_class = "STANDARD"
    }
  }

  depends_on = [aws_s3_bucket_versioning.logs]
}

resource "aws_s3_bucket_replication_configuration" "app_data" {
  bucket = aws_s3_bucket.app_data.id
  role   = aws_iam_role.s3_replication.arn

  rule {
    id     = "replicate-app-data-cross-region"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.app_data_replica.arn
      storage_class = "STANDARD"
    }
  }

  depends_on = [aws_s3_bucket_versioning.app_data]
}
