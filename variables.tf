variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "action_groups" {
  type = list(object({
      name = string,
      short_name = string,
      email_receivers = list(object({ name = string, email_address = string }))
  }))
  default = []
}

variable "query_alert_rules" {
  type = list(object({
    name = string
    description = optional(string),
    enabled = bool,
    evaluation_frequency = string,
    scope = string,
    severity = number,
    window_duration = string,
    auto_mitigation_enabled = optional(bool, false),
    workspace_alerts_storage_enabled = optional(bool, false),
    mute_actions_after_alert_duration = optional(string),
    query_time_range_override = optional(string),
    skip_query_validation = optional(bool, false),
    target_resource_types = optional(set(string)),
    action_group_names = set(string),
    action_custom_properties = optional(map(string)),

    criteria = object({
      operator = string,
      query = string,
      threshold = number,
      time_aggregation_method = string,
      metric_measure_column = optional(string),
      resource_id_column = optional(string),

      dimension = optional(object({
        name = string,
        operator = string,
        values = set(string)
      })),

      failing_periods = optional(object({
        minimum_failing_periods_to_trigger_alert = number,
        number_of_evaluation_periods = number
      }))
    })
  }))

  default = []                                                                                                                                                                                                                                             
}

