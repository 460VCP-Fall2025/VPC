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
resource "local_file" "unix_send_request_script" {
  filename = "../webclient/unix_send_request.sh"

  content = <<-EOF
    #!/usr/bin/env bash
    python3 webclient.py ${aws_lb.nlb.dns_name} 8080 response.html
  EOF
}

//Making the send_request.sh script locally
resource "local_file" "win_send_request_script" {
  filename = "../webclient/win_send_request.sh"

  content = <<-EOF
    #!/usr/bin/env bash
    python webclient.py ${aws_lb.nlb.dns_name} 8080 response.html
  EOF
}


















