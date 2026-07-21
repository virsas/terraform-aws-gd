resource "aws_guardduty_detector" "vss" {
  enable = true
}

resource "aws_guardduty_detector_feature" "vss" {
  for_each    = toset(var.features_list)
  detector_id = aws_guardduty_detector.vss.id
  name        = each.key
  status      = "ENABLED"

  dynamic "additional_configuration" {
    for_each = each.key == "RUNTIME_MONITORING" ? ["EKS_ADDON_MANAGEMENT", "ECS_FARGATE_AGENT_MANAGEMENT", "EC2_AGENT_MANAGEMENT"] : []
    content {
      name   = additional_configuration.value
      status = "DISABLED"
    }
  }
}

resource "aws_guardduty_organization_admin_account" "vss" {
  count            = var.admin_create ? 1 : 0
  admin_account_id = var.admin_account_id
}

resource "aws_guardduty_organization_configuration" "vss" {
  count      = var.admin_create ? 1 : 0
  depends_on = [aws_guardduty_organization_admin_account.vss]

  auto_enable_organization_members = var.org_auto_enable
  detector_id                      = aws_guardduty_detector.vss.id
}

resource "aws_guardduty_organization_configuration_feature" "vss" {
  for_each    = var.admin_create ? toset(var.features_list) : []
  detector_id = aws_guardduty_detector.vss.id
  name        = each.key
  auto_enable = var.org_auto_enable

  dynamic "additional_configuration" {
    for_each = each.key == "RUNTIME_MONITORING" ? ["ECS_FARGATE_AGENT_MANAGEMENT", "EC2_AGENT_MANAGEMENT", "EKS_ADDON_MANAGEMENT"] : []
    content {
      name        = additional_configuration.value
      auto_enable = "NONE"
    }
  }
}

resource "aws_guardduty_publishing_destination" "vss" {
  count = (var.s3_arn != null) ? 1 : 0

  detector_id     = aws_guardduty_detector.vss.id
  destination_arn = var.s3_arn
  kms_key_arn     = var.kms_arn
}