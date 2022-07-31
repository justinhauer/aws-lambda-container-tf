variable "function_name" {
  type = string
}

variable "package_type" {
  type    = string
  default = "Image"
}

variable "cloudwatch_logs" {
  description = "Set this to false to disable logging your lambda output to Cloudwatch logs"
  type        = bool
  default     = true
}

variable "policy" {
  description = "An additional policy to attach to the lambda function role"
  type = object({
    json = string
  })
  default = null
}

variable "trusted_entities" {
  description = "lambda function additional trusted entities for assuming roles (trust relationship)"
  type        = list(string)
  default     = []

}

variable "description" {
  type    = string
  default = null

}

variable "kms_key_arn" {
  type    = string
  default = null
}

variable "memory_size" {
  type    = number
  default = null
}

variable "reserved_concurrent_executions" {
  type    = number
  default = null
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "timeout" {
  type    = number
  default = 3
}

variable "dead_letter_config" {
  type = object({
    target_arn = string
  })
  default = null
}

variable "environment" {
  type = object({
    variables = map(string)
  })
  default = null
}

variable "vpc_config" {
  type = object({
    security_group_ids = list(string)
    subnet_ids         = list(string)
  })
  default = null
}

variable "enabled" {
  description = "Enable or disable the lambda resource"
  type        = bool
  default     = true
}

variable "image_uri" {
  description = "URI of container image in ECR"
  type        = string
}

variable "log_retention_days" {
  description = "Amount of says logs are kept in cloudwatch logs"
}