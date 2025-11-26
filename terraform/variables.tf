
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

locals {
  blue_enabled  = var.enable_blue_env
  green_enabled = var.enable_green_env
}





//Making the send_request.sh script locally
resource "local_file" "send_request_script" {
  filename = "../webclient/send_request.sh"

  content = <<-EOF
    #!/usr/bin/env bash
    python3 webclient.py ${aws_lb.nlb.dns_name} 8080 response.html
  EOF
}


















