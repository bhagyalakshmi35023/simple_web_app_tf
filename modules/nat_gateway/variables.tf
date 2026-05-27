variable "subnet_id" {
  description = "The public subnet ID where the NAT Gateway is placed"
  type        = string
}

variable "allocation_id" {
  description = "The EIP allocation ID for the NAT Gateway"
  type        = string
}

variable "name" {
  description = "Name tag for the NAT Gateway"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the NAT Gateway"
  type        = map(string)
  default     = {}
}
