data "aws_iam_policy_document" "assume_role" {
  count = var.enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = concat(slice(["lambda.amazonaws.com", "edgelambda.amazonaws.com"], 0, var.lambda_at_edge ? 2 : 1), var.trusted_entities)
    }
  }
}

resource "aws_iam_role" "lambda" {
  count              = var.enabled ? 1 : 0
  name               = var.function_name
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
  tags               = var.tags
}

locals {
  lambda_log_group_arn      = "arn:${data.aws_partition.current.partition}:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.function_name}"
  lambda_edge_log_group_arn = "arn:${data.aws_partition.current.partition}:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${data.aws_region.current.name}.${var.function_name}"
  log_group_arns            = slice([local.lambda_log_group_arn, local.lambda_edge_log_group_arn], 0, var.lambda_at_edge ? 2 : 1)
}

data "aws_iam_policy_document" "logs" {
  count = var.enabled && var.cloudwatch_logs ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = concat(formatlist("%v:*", local.log_group_arns), formatlist("%v:*:*", local.log_group_arns))
  }
}

resource "aws_iam_policy" "logs" {
  count      = var.enabled && var.cloudwatch_logs ? 1 : 0
  name       = "${var.function_name}-logs"
  roles      = [aws_iam_role.lambda[0].name]
  policy_arn = aws_iam_policy.logs[0].arn
}

data "aws_iam_policy_document" "dead_letter" {
  count = var.dead_letter_config == null ? 0 : var.enabled ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sqs:SendMessage",
    ]
    resources = [
      var.dead_letter_config.target_arn
    ]
  }

}

resource "aws_iam_policy" "dead_letter" {
  count  = var.dead_letter_config == null ? 0 : var.enabled ? 1 : 0
  name   = "${var.function_name}-dl"
  policy = data.aws_iam_policy_document.dead_letter[0].json
}

resource "aws_iam_policy_attachment" "dead_letter" {
  count      = var.dead_letter_config == null ? 0 : var.enabled ? 1 : 0
  name       = "${var.function_name}-dl"
  roles      = [aws_iam_role.lambda[0].name]
  policy_arn = aws_iam_policy.dead_letter[0].arn
}

data "aws_iam_policy_document" "network" {
  count = var.vpc_config == null ? 0 : var.enabled ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "network" {
  count      = var.vpc_config == null ? 0 : var.enabled ? 1 : 0
  name       = "${var.function_name}-network"
  policy_arn = data.aws_iam_policy_document.network[0].json
}

resource "aws_iam_policy_attachment" "network" {
  count      = var.vpc_config == null ? 0 : var.enabled ? 1 : 0
  name       = "${var.function_name}-network"
  roles      = [aws_iam_role.lambda[0].name]
  policy_arn = aws_iam_policy.network[0].arn
}

resource "aws_iam_policy" "additional" {
  count      = var.policy == null ? 0 : var.enabled ? 1 : 0
  name       = var.function_name
  roles      = [aws_iam_role.lambda[0].name]
  policy_arn = aws_iam_policy.additional[0].arn

}