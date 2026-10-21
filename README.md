# Terraform AWS GuardDuty Module

A Terraform module for managing [Amazon GuardDuty](https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html). It enables a GuardDuty detector in the current account and region, turns on a configurable set of protection features, and optionally designates the account as the organization delegated administrator and exports findings to an S3 bucket.

## Features

- **Detector Management**: Always creates and enables a GuardDuty detector in the account and region of the provider.
- **Feature Selection**: Enables each protection feature listed in `features_list`, such as S3 data events, EBS malware protection, RDS login events, runtime monitoring and Lambda network logs.
- **RDS Login Events**: Manages `RDS_LOGIN_EVENTS` with its own detector and organization feature resources, and ignores `additional_configuration` so AWS-managed settings do not show as perpetual drift.
- **Runtime Monitoring Sub-features**: For `RUNTIME_MONITORING`, explicitly disables automated agent management for EKS, ECS Fargate and EC2 so agents are managed outside of GuardDuty.
- **Delegated Administrator**: Optionally designates a GuardDuty delegated admin account for AWS Organizations.
- **Organization Auto-enable**: When acting as delegated admin, sets whether GuardDuty and each feature are enabled automatically for organization member accounts.
- **Findings Export**: Optionally configures a publishing destination so findings are exported to an S3 bucket, encrypted with a KMS key.

---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

---

## Usage Examples

### Basic Example

Enable a detector with the default set of protection features:

```hcl
module "guardduty" {
  source = "git::https://github.com/virsas/terraform-aws-gd.git?ref=v1.2"
}
```

### Reduced Feature Set

Enable only the features you need by overriding `features_list`:

```hcl
module "guardduty_minimal" {
  source = "git::https://github.com/virsas/terraform-aws-gd.git?ref=v1.2"

  features_list = [
    "S3_DATA_EVENTS",
    "RDS_LOGIN_EVENTS"
  ]
}
```

### Advanced Example (Delegated Admin & Organization)

Designate the security account as GuardDuty delegated administrator and automatically enable GuardDuty and all listed features for every account in the organization. This must be applied from the organization management account:

```hcl
module "guardduty_admin" {
  source = "git::https://github.com/virsas/terraform-aws-gd.git?ref=v1.2"

  admin_create     = true
  admin_account_id = "123456789012"
  org_auto_enable  = "ALL"

  features_list = [
    "S3_DATA_EVENTS",
    "EBS_MALWARE_PROTECTION",
    "RDS_LOGIN_EVENTS",
    "RUNTIME_MONITORING",
    "LAMBDA_NETWORK_LOGS"
  ]
}
```

### Exporting Findings to S3

Publish findings to an S3 bucket encrypted with a customer managed KMS key. The bucket policy and key policy must already allow the GuardDuty service to write and encrypt:

```hcl
module "guardduty_export" {
  source = "git::https://github.com/virsas/terraform-aws-gd.git?ref=v1.2"

  s3_arn  = "arn:aws:s3:::vss-guardduty-findings"
  kms_arn = "arn:aws:kms:eu-west-1:123456789012:key/12345678-1234-1234-1234-123456789012"
}
```

---

## Resources

| Name | Type |
|------|------|
| [aws_guardduty_detector.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector) | resource |
| [aws_guardduty_detector_feature.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector_feature) | resource |
| [aws_guardduty_detector_feature.rds_login_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector_feature) | resource |
| [aws_guardduty_organization_admin_account.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account) | resource |
| [aws_guardduty_organization_configuration.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration) | resource |
| [aws_guardduty_organization_configuration_feature.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration_feature) | resource |
| [aws_guardduty_organization_configuration_feature.rds_login_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration_feature) | resource |
| [aws_guardduty_publishing_destination.vss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_publishing_destination) | resource |

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_features_list"></a> [features\_list](#input\_features\_list) | List of GuardDuty protection features to enable. Allowed values are `S3_DATA_EVENTS`, `EKS_AUDIT_LOGS`, `EBS_MALWARE_PROTECTION`, `RDS_LOGIN_EVENTS`, `EKS_RUNTIME_MONITORING`, `LAMBDA_NETWORK_LOGS` and `RUNTIME_MONITORING`. | `list(string)` | <pre>[<br>  "S3_DATA_EVENTS",<br>  "EBS_MALWARE_PROTECTION",<br>  "RDS_LOGIN_EVENTS",<br>  "RUNTIME_MONITORING",<br>  "LAMBDA_NETWORK_LOGS"<br>]</pre> | no |
| <a name="input_admin_create"></a> [admin\_create](#input\_admin\_create) | Whether to designate a GuardDuty delegated administrator and manage the organization configuration. | `bool` | `false` | no |
| <a name="input_admin_account_id"></a> [admin\_account\_id](#input\_admin\_account\_id) | AWS account ID to designate as the GuardDuty delegated administrator. Required when `admin_create` is `true`. | `string` | `null` | no |
| <a name="input_org_auto_enable"></a> [org\_auto\_enable](#input\_org\_auto\_enable) | Whether GuardDuty and its features are enabled automatically for organization member accounts. Allowed values are `ALL`, `NEW` and `NONE`. Only used when `admin_create` is `true`. | `string` | `"ALL"` | no |
| <a name="input_s3_arn"></a> [s3\_arn](#input\_s3\_arn) | ARN of the S3 bucket used as the GuardDuty findings export destination. Leaving this `null` skips the publishing destination. | `string` | `null` | no |
| <a name="input_kms_arn"></a> [kms\_arn](#input\_kms\_arn) | ARN of the KMS key used to encrypt exported GuardDuty findings. Required by the GuardDuty API whenever `s3_arn` is set. | `string` | `null` | no |

---

## Outputs

This module exposes no outputs.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
