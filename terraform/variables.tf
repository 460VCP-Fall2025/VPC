# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0





variable "active_env" {
  description = "blue or green"
  type        = string
  default     = "blue"
}

locals {
  active_tg = var.active_env == "blue" ? aws_lb_target_group.blue.arn : aws_lb_target_group.green.arn
}

variable "enable_blue_env" {
  description = "Enable blue environment"
  type        = bool
  default     = true
}

variable "blue_instance_count" {
  description = "Number of instances in blue environment"
  type        = number
  default     = 1
}

