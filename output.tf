output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = join("", aws_lambda_function.lambda.*.arn)
}

output "function_invoke_arn" {
  value       = join("", aws_lambda_function.lambda.*.invoke_arn)
  description = "The Invoke ARN of the Lambda Function"
}

output "function_name" {
  value       = join("", aws_lambda_function.lambda.*.function_name)
  description = "The name of the function"
}

output "function_qualified_arn" {
  value       = join("", aws_lambda_function.lambda.*.qualified_arn)
  description = "the qualified arn"
}

output "role_arn" {
  value       = join("", aws_iam_role.lambda.*.arn)
  description = "The ARN of the iam role created for the lambda function"
}

output "role_name" {
  value       = join("", aws_iam_role.lambda.*.name)
  description = "The name of the IAM role created for the lambda"
}

output "log_group_arn" {
  description = "The name of the log group for the lambda"
  value       = local.lambda_log_group_arn
}