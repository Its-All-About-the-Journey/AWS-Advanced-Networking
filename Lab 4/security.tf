# Grants user full access to S3 so it can modify ACL rules.
resource "aws_iam_policy_attachment" "s3_full_access" {
  name       = "s3_full_access_attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  users      = ["iamadmin"]
}
