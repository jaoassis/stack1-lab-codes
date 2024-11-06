variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "region" {
  description = "region name"
  type        = string
  default     = "sa-east-1"
}

variable "session_name" {
  description = "Session name of the deployment role in the account to deploy the resources"
  type        = string
  default     = null
}

variable "account_id" {
  description = "account id"
  type        = string
  default     = "account-id-number"
}


variable "tags" {
  description = "Key-value map of additional resource tags."
  type        = map(string)
  default     = {}
}


variable "function_name" {
  description = "function name"
  type        = string
  default     = "stack1-lab"

}

variable "function_description" {
  description = "function description"
  type        = string
  default     = "stack1 lab"

}

variable "handler" {
  description = "function handler"
  type        = string
  default     = "handler.handler" 

}

variable "runtime" {
  description = "lambda runtime"
  type        = string
  default     = "python3.12" 

}

variable "bucket_package" {
  description = "bucket name for default package"
  type        = string
  default     = "default-packages-bucket"
}

variable "webhook_secret" {
  description = "secret name"
  type        = string
  default     = "demo-webhook"
}