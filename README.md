# Terraform AWS Lambda

Terraform module to easily create AWS Lambda Functions from containers. Keeps it simple and removes the cruft you don't care to write

## What does it do?

- Opinionated lambda deployments from containers
- Creates components for CW logs, normally you can't controll the log retention
- Optionally add additional IAM policies
- Import via a module into your project

## Version compatibility
- Tested with TF version 1.x.x


## Prerequisites
- Container image is uploaded in ECR
- Container image can be run in a lambda. see reference [here](https://docs.aws.amazon.com/lambda/latest/dg/python-image.html)

## Example Deployment

For the example below, the source would be the remote path to this git repository

```hcl

terraform {
    backend "s3" {}
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
    repository = "example_namespace/example_repo_name"
    image_tag = "1.0.0"
}

data "aws_iam_policy_document" "ecr_actions" {
    statement {
        effect = "Allow"
        actions = [
            "ecr:DescribeImages"
        ]
        resources = [
            "*"
        ]
    }
}

module "container_lambda" {
    source = "some_remote_path_you_should_change"
    function_name = "example"
    description = "example_lambda"
    package_type = "Image"
    memory_size = 256
    reserved_concurrent_executions = 2
    timeout = 300
    image_uri = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.repository}:$local.image_tag}"
    log_retention_days = 7
    enabled = true
    policy = {
        json = data.aws)iam_policy_document.ecr_actions.json
    }
    environment = {
        variables = {
            ARN = "example-arn"
        }
    }
}

output "function_arn" {
    description = "lambda arn"
    value = module.container_lambda.role_arn
}
```
## Inputs

Inputs are the same as referenced in the terraform docs for AWS Lambda with the following additional arguments:

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | -------- |
|cloudwatch_logs | Set to false to disable logs on lambda | `bool` | `true` | no |
| policy | an additional policy to attach to the lambda function role | `object({json=string})` | None | no |
| trusted_entities | Additional trusted entities for the lambda function. lambda.amazonaws.com is always set | `list(string)` | None | no |
| enabled | Enabling or disabling all resources | `bool` | `true` | no |

## outputs

See `output.tf` for descriptions 