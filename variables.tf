variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources to."
  default = "us-west-2"
}

variable "name" {
  type        = string
  description = "Root name tag to apply to resources in the module. Will be prepended to some resource names"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to resources in the module"
  default     = {}
}

variable "api_description" {
    type = string
    description = "Description to apply to the API Gateway API, visible in the console"
    default = ""
}
variable "stage_name" {
    type = string
    description = "Name to use for the stage in API Gateway, affects final URL"
    default = "v0"
}
variable "api_path_part" {
    type = string
    description = "String to use for path part of API Gateway integration, affects final URL"
}

variable "lambda_timeout" {
  type        = number
  description = "Timeout for the lambda function, in seconds"
  default     = 3
}

variable "lambda_memory" {
  type        = number
  description = "Amount of memory to allocate to the Lambda function. 128 MB to 3,008 MB, in 64 MB increments"
  default     = 128
}

variable "lambda_handler" {
  type        = string
  description = "The handler reference for the Lambda, usually index.handler (format is path/to/filename.exported_function_name)"
  default     = "index.handler"
}

variable "lambda_runtime" {
  type        = string
  description = "The runtime to use in the scraper Lambda, IE nodejs8.10 or python3.7"
  default     = "nodejs12.x"
}

