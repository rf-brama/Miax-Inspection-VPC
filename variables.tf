variable "vpcendpointeast" {
  description = "Vpce endpoint for networkfirewall"
  type        = string
  default     = "vpce-05e5eca677ac5e145"
}

variable "cidropen" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR"
  type        = string
  default     = "0.0.0.0/0"
}