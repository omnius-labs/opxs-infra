resource "aws_s3_bucket" "opxs_web" {
  bucket        = "opxs.v1.${var.run_mode}.web"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "opxs_web" {
  bucket = aws_s3_bucket.opxs_web.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Allow CloudFront",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_cloudfront_origin_access_identity.opxs.iam_arn}"
      },
      "Action": "s3:GetObject",
      "Resource":"${aws_s3_bucket.opxs_web.arn}/*"
    }
  ]
}
EOF
}
