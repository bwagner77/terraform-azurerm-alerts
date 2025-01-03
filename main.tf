resource "azurerm_monitor_action_group" "action_groups" {
  for_each            = { for idx, ag in var.action_groups : ag.name => ag }
  resource_group_name = var.resource_group_name
  name                = each.value.name
  short_name          = substr(each.value.short_name, 0, 12)

  dynamic "email_receiver" {
    for_each = each.value.email_receivers
    content = {
      name                    = email_receiver.value["name"]
      email_address           = email_receiver.value["email_address"]
      use_common_alert_schema = true
    }
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "query_alert_rules" {
  for_each            = { for idx, qar in var.query_alert_rules : qar.name => qar }
  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  description         = each.value.description
  enabled             = each.value.enabled
  display_name        = each.value.name

  evaluation_frequency              = each.value.evaluation_frequency
  scopes                            = [each.value.scope]
  severity                          = each.value.severity
  window_duration                   = each.value.window_duration
  auto_mitigation_enabled           = each.value.auto_mitigation_enabled
  workspace_alerts_storage_enabled  = each.value.workspace_alerts_storage_enabled
  mute_actions_after_alert_duration = each.value.mute_actions_after_alert_duration
  query_time_range_override         = each.value.query_time_range_override
  skip_query_validation             = each.value.skip_query_validation
  target_resource_types             = each.value.target_resource_types

  action {
    action_groups     = toset([for ag in azurerm_monitor_action_group.action_groups : ag.id if contains(each.value.action_group_names, ag.name)])
    custom_properties = each.value.action_custom_properties
  }

  criteria {
    operator                = each.value.criteria.operator
    query                   = each.value.criteria.query
    threshold               = each.value.criteria.threshold
    time_aggregation_method = each.value.criteria.time_aggregation_method
    metric_measure_column   = each.value.criteria.metric_measure_column
    resource_id_column      = each.value.criteria.resource_id_column

    dynamic "dimension" {
      for_each = each.value.criteria.dimension[*]
      content {
        name     = each.value.criteria.dimension.name
        operator = each.value.criteria.dimension.operator
        values   = each.value.criteria.dimension.values
      }
    }

    dynamic "failing_periods" {
      for_each = each.value.criteria.failing_periods[*]
      content {
        minimum_failing_periods_to_trigger_alert = each.value.criteria.failing_periods.minimum_failing_periods_to_trigger_alert
        number_of_evaluation_periods             = each.value.criteria.failing_periods.number_of_evaluation_periods
      }
    }
  }

  lifecycle {
    ignore_changes = [
      enabled
    ]
  }
}