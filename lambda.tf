resource "aws_lambda_function" "lambda" {
  count                          = var.enabled ? 1 : 0
  function_name                  = var.function_name
  description                    = var.description
  role                           = aws_iam_role.lambda[0].arn
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions
  timeout                        = local.timeout
  tags                           = var.tags
  package_type                   = var.package_type
  image_uri                      = var.image_uri

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_config == null ? [] : [var.dead_letter_config]
    content {
      target_arn = dead_letter_config.value.target_arn
    }
  }

  dynamic "environment" {
    for_each = var.environment == null ? [] : [var.environment]
    content {
      variables = environment.value.variables
    }
  }
  dynamic "tracing_config" {
    for_each = var.tracing_config == null ? [] : [var.tracing_config]
    content {
      mode = tracing_config.value.mode
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [var.vpc_config]
    content {
      security_group_ids = vpc_config.value.security_group_ids
      subnet_ids         = vpc_config.value.subnet_ids
    }
  }
}

resource "aws_cloudwatch_log_group" "cve_examiner_logs" {
  count             = var.enabled && var.cloudwatch_logs ? 1 : 0
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
}