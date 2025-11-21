

#Sets blue or green as currently active environment
variable "active_env" {
  description = "Active environment: blue or green (the other will be disabled)"
  type        = string
  default     = "blue"

  validation {
    condition     = contains(["blue", "green"], var.active_env)
    error_message = "Active environment must be either 'blue' or 'green'."
  }
}

# Derived local variables
locals {
  active_tg = var.active_env == "blue" ? aws_lb_target_group.blue.arn : aws_lb_target_group.green.arn

  # Automatically enable the active environment and disable the other
  enable_blue_env  = var.active_env == "blue"
  enable_green_env = var.active_env == "green"
}


















