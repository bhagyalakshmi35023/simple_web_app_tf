variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "name" {
  description = "The name of the VPC"
  type        = string
}

variable "enable_dns_support" {
  description = "Enable DNS resolution in the VPC"
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames for instances in the VPC"
  type        = bool
}

variable "tags" {
  description = "Tags to apply to the VPC"
  type        = map(string)
  default     = {}
}
