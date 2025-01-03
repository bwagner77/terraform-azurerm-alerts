output "action_groups" {
  value = azurerm_monitor_action_group.action_groups
}

output "query_alert_rules" {
  value = azurerm_monitor_scheduled_query_rules_alert_v2.query_alert_rules
}