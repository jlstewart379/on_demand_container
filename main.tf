provider "aws" {
  region="${var.region}"
}
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role-"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "codebuild_policy" {
  name        = "codebuild-policy"
  path        = "/service-role/"
  description = "Policy used in trust relationship with CodeBuild"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "s3:PutObject",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  name       = "codebuild-policy-attachment"
  policy_arn = "${aws_iam_policy.codebuild_policy.arn}"
  roles      = ["${aws_iam_role.codebuild_role.id}"]
}

resource "aws_codebuild_project" "on_demand_container" {
  name         = "on_demand_container"
  description  = "Codebuild project for on demand container"
  service_role = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "S3"
    location = "${var.bucket_name}"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/eb-python-3.4-amazonlinux-64:2.1.6"
    type         = "LINUX_CONTAINER"
  }

  source {
    type     = "GITHUB"
    location = "https://github.com/jlstewart379/on_demand_container.git"
  }
}

resource "aws_s3_bucket" "landing_spot" {
  bucket = "${var.bucket_name}"
  acl = "private"
}

resource "aws_s3_bucket_policy" "landing_spot_bucket_policy" {
  bucket = "${aws_s3_bucket.landing_spot.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Principal": "*",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "${aws_s3_bucket.landing_spot.arn}"
    }
  ]
}
EOF
}

variable "bucket_name"{
  description = "The bucket to dump the data."
}

variable "region" {
  description = "The region"
}
