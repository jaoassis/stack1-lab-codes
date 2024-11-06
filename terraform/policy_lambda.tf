data "aws_iam_policy_document" "policy_lambda_sg" {

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:${var.region}:${var.account_id}:*",
    ]
  }

    statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]

    resources = [
      "arn-secret"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
        "ec2:RevokeSecurityGroupIngress"
    ]

    resources = ["*"]
  }
}


data "aws_iam_policy_document" "assume_role_policy" {

  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "policy_lambda" {
  name   = "stack1-lab-policy-1"
  policy = data.aws_iam_policy_document.policy_lambda_sg.json
}



resource "aws_iam_role" "role" {

  name               = "stack1-lab-service-1"
  description        = "Stack1 lab Service Role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = { "environment" = var.environment }
}

resource "aws_iam_role_policy_attachment" "policy_attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy_lambda.arn
}