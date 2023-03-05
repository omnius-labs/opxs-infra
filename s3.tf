resource "aws_s3_bucket" "opxs_web" {
  bucket        = "opxs.v1.web"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "opxs_web" {
  bucket = aws_s3_bucket.opxs_web.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "opxs_web" {
  bucket = aws_s3_bucket.opxs_web.id
  policy = data.aws_iam_policy_document.opxs_web_policy.json
}

data "aws_iam_policy_document" "opxs_web_policy" {
  statement {
    sid    = "Allow CloudFront"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.opxs.iam_arn]
    }
    actions = [
      "s3:GetObject"
    ]
    resources = ["${aws_s3_bucket.opxs_web.arn}/*"]
  }
}
