
/*
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


variable "enable_green_env" {
  description = "Enable green environment"
  type        = bool
  default     = true
}



variable "enable_blue_env" {
  description = "Enable blue environment"
  type        = bool
  default     = false
}

*/

# ---------------------------------------------------
# Enable BLUE environment?
# ---------------------------------------------------
variable "enable_blue_env" {
  description = "Enable the BLUE environment (true = blue active)"
  type        = bool
  default     = false
}

# ---------------------------------------------------
# Enable GREEN environment?
# ---------------------------------------------------
variable "enable_green_env" {
  description = "Enable the GREEN environment (true = green active)"
  type        = bool
  default     = false
}

# ---------------------------------------------------
# Safety: Ensure only one environment is active
# ---------------------------------------------------
locals {
  env_conflict = (
    var.enable_blue_env && var.enable_green_env ?
    "ERROR: You cannot enable both BLUE and GREEN at the same time." :
    null
  )
}


















