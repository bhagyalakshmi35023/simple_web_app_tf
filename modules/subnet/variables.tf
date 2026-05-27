variable "vpc_id" {
  description = "The VPC ID for the subnet"
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block for the subnet"
  type        = string
}

variable "availability_zone" {
  description = "The availability zone for the subnet (e.g. us-east-1a)"
  type        = string
}

variable "map_public_ip_on_launch" {
  description = "Whether to assign a public IP to instances launched in this subnet"
  type        = bool
  default     = false
}

variable "name" {
  description = "Name tag for the subnet"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the subnet"
  type        = map(string)
  default     = {}
}
