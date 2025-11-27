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
  
  validation {
    //Checks that one and only one of the environments is set to true
    //Does not check when terraform destroying, which is what var.skip_validation is
    condition = var.skip_validation || (var.enable_blue_env != var.enable_green_env)
    
    error_message = <<-EOT
      Configuration Error: Exactly one environment (BLUE or GREEN) must be active.

      *** To set the blue environment on, run: terraform apply -var="enable_blue_env=true" -var="enable_green_env=false" **
      *** To set the green environment on, run: terraform apply -var="enable_blue_env=false" -var="enable_green_env=true" ***
      *** To run destroy, use: terraform destroy -var="skip_validation=true" ***
      EOT
  }
}

# ---------------------------------------------------
# Skip the blue/green validation when destroying
# ---------------------------------------------------
variable "skip_validation" {
  description = "Set to true during terraform destroy to skip validation checks."
  type        = bool
  default     = false
}




