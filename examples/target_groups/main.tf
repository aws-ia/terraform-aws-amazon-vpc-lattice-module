# --- examples/target_groups/main.tf ---

module "vpclattice_target_groups" {
  source = "../.."

  target_groups = {
    lambdatarget = {
      type = "LAMBDA"
      targets = {
        mylambda = { id = aws_lambda_function.lambda.arn }
      }
    }

    iptarget = {
      type = "IP"
      config = {
        port             = 80
        protocol         = "HTTP"
        vpc_identifier   = module.vpc.vpc_attributes.id
        ip_address_type  = "IPV4"
        protocol_version = "HTTP1"
      }
      health_check = {
        enabled = false
      }
      targets = {
        ip1 = {
          id   = "10.0.0.10"
          port = 80
        }
        ip2 = {
          id   = "10.0.0.20"
          port = 80
        }
        ip3 = {
          id   = "10.0.0.30"
          port = 80
        }
      }
    }

    albtarget = {
      type = "ALB"
      config = {
        port             = 443
        protocol         = "HTTPS"
        vpc_identifier   = module.vpc.vpc_attributes.id
        protocol_version = "HTTP2"
      }
    }
  }
}

# VPC - to create IP targets
module "vpc" {
  source  = "aws-ia/vpc/aws"
  version = "4.4.4"

  name       = "vpc"
  cidr_block = "10.0.0.0/24"
  az_count   = 2

  subnets = {
    workload = { netmask = 28 }
  }
}

# AWS Lambda Function and Role
resource "aws_lambda_function" "lambda" {
  function_name    = "mylambda"
  filename         = "lambda_function.zip"
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256

  role    = aws_iam_role.lambda_role.arn
  runtime = "python3.10"
  handler = "lambda_function.lambda_handler"
}

data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/function.py"
  output_path = "lambda_function.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-route53-role"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = data.aws_iam_policy_document.lambda_policy_document.json
}

data "aws_iam_policy_document" "lambda_policy_document" {
  statement {
    sid    = "LambdaLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "lambda-logging-policy-attachment"
  roles      = [aws_iam_role.lambda_role.id]
  policy_arn = aws_iam_policy.lambda_policy.arn
}