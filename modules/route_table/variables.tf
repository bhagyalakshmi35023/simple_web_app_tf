variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "cidr_block" {
  description = "The destination CIDR block for the route (e.g. 0.0.0.0/0)"
  type        = string
}

variable "name" {
  description = "Name tag for the route table (e.g. si-prod-public-rt, si-prod-private-rt)"
  type        = string
}

variable "gateway_id" {
  description = "Internet Gateway ID — set for public route tables, null for private"
  type        = string
  default     = null
}

variable "nat_gateway_id" {
  description = "NAT Gateway ID — set for private route tables, null for public"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with this route table"
  type        = map(string)
}

variable "tags" {
  description = "Tags to apply to the route table"
  type        = map(string)
  default     = {}
}
