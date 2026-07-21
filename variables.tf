variable "features_list" {
  description = "List of GuardDuty features to enable."
  type        = list(string)
  default     = [
    "S3_DATA_EVENTS",
    "EBS_MALWARE_PROTECTION",
    "RDS_LOGIN_EVENTS",
    "RUNTIME_MONITORING",
    "LAMBDA_NETWORK_LOGS"
  ]
}

variable "admin_create" {
  description = "Set to true if this account is the GuardDuty Delegated Admin."
  type        = bool
  default     = false
}

variable "admin_account_id" {
  description = "The AWS Account ID to be the GuardDuty Admin."
  type        = string
  default     = null
}

variable "org_auto_enable" {
  description = "Auto-enable GuardDuty for new accounts in the org. Valid values: ALL, NEW, NONE."
  type        = string
  default     = "ALL"
}

variable "s3_arn" {
  description = "S3 bucket ARN for GuardDuty finding exports."
  type        = string
  default     = null
}

variable "kms_arn" {
  description = "KMS key ARN for encrypting GuardDuty finding exports."
  type        = string
  default     = null
}