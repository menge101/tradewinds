provider "aws" {
  version                 = "~> 2.43"
  region                  = var.region
  shared_credentials_file = var.cred_file
  profile                 = var.profile
}

data "aws_iam_policy_document" "tradewinds-ci-policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:us-east-2:347157418948:log-group:/aws/codebuild/${var.project_name}",
      "arn:aws:logs:us-east-2:347157418948:log-group:/aws/codebuild/${var.project_name}:*",
      "arn:aws:logs:us-east-2:347157418948:log-group:tradewinds-ci",
      "arn:aws:logs:us-east-2:347157418948:log-group:tradewinds-ci:*"
    ]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::codepipeline-us-east-2-*"
    ]
  }

  statement {
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases"
    ]
    resources = [
      "arn:aws:codebuild:us-east-2:347157418948:report-group/${var.project_name}-*"
    ]
  }

  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositores",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer"
    ]
    resources = [
      "arn:aws:ecr:us-east-2:347157418948:repository/${var.codebuild_image}"
    ]
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "ssm:GetParameters"
    ]
    resources = [
      "arn:aws:ssm:us-east-2:347157418948:parameter/*"
    ]
  }
}

resource "aws_ssm_parameter" "auth0_secret" {
  name        = "/${var.project_name}/auth0/client_secret"
  description = "Auth0 client secret"
  type        = "SecureString"
  value       = var.auth0_client_secret

  tags = {
    environment = "test"
    project = var.project_name
  }
}

resource "aws_iam_role" "tradewinds-ci-role" {
  name = "${var.project_name}-role"
  assume_role_policy = file("${path.module}/assume_role_policy.json")
}

resource "aws_iam_role_policy" "tradewinds-ci-role-policy" {
  role = aws_iam_role.tradewinds-ci-role.name
  policy = data.aws_iam_policy_document.tradewinds-ci-policy.json
}

resource "aws_codebuild_project" "tradewinds_ci" {
  depends_on    = []
  name          = var.project_name
  description   = "CI for Tradewinds"
  build_timeout = "5"
  service_role  = aws_iam_role.tradewinds-ci-role.arn
  badge_enabled = true

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "${var.codebuild_prefix}/${var.codebuild_image}:${var.codebuild_image_version}"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"


    environment_variable {
      name  = "AUTH0_CLIENT_SECRET"
      value = aws_ssm_parameter.auth0_secret.name
      type = "PARAMETER_STORE"
    }

    environment_variable {
      name = "AUTH0_CLIENT_ID"
      value = var.auth0_client_id
    }

    environment_variable {
      name = "AUTH0_DOMAIN"
      value = var.auth0_domain
    }

  }

  logs_config {
    cloudwatch_logs {
      group_name = var.project_name
      stream_name = "builds"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/menge101/tradewinds"
    git_clone_depth = 1
    report_build_status = true
  }

  tags = {
    Environment = "Test"
    Project = "Tradewinds"
  }
}

resource "aws_codebuild_webhook" "tradewinds-ci-codebuild-webhook" {
  project_name = aws_codebuild_project.tradewinds_ci.name

  filter_group {
    filter {
      type = "EVENT"
      pattern = "PUSH, PULL_REQUEST_CREATED, PULL_REQUEST_UPDATED, PULL_REQUEST_REOPENED, PULL_REQUEST_MERGED"
    }
  }
}
