# DEMO ONLY — Checkov/terraform failures

resource "aws_s3_bucket" "demo_insecure" {
  bucket = "${var.project_name}-${var.environment}-wide-open-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.project_name}-insecure"
  }
}

resource "aws_s3_bucket_acl" "demo_insecure" {
  bucket = aws_s3_bucket.demo_insecure.id
  acl    = "public-read"

  depends_on = [aws_s3_bucket_ownership_controls.demo_insecure]
}

resource "aws_s3_bucket_ownership_controls" "demo_insecure" {
  bucket = aws_s3_bucket.demo_insecure.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_iam_policy" "demo_star_star" {
  name        = "${var.project_name}-demo-admin"
  description = "DEMO: wildcard IAM — Checkov should fail"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_user" "demo_no_mfa" {
  name = "${var.project_name}-demo-user"
}

resource "aws_iam_user_policy_attachment" "demo_no_mfa" {
  user       = aws_iam_user.demo_no_mfa.name
  policy_arn = aws_iam_policy.demo_star_star.arn
}
