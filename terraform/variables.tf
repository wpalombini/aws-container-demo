variable "environment" {
  description = "The environment to deploy to"
  type        = string

  default = "dev"

  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "Environment must be one of 'dev', 'stg', or 'prod'"
  }
}

variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "ap-southeast-2"
}

variable "aws_profile" {
  description = "The AWS profile to use"
  type        = string
  default     = "walter-personal"
}
