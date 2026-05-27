variable "vpc_id" {
  description = "The VPC ID to attach the Internet Gateway to"
  type        = string
}

variable "name" {
  description = "Name tag for the Internet Gateway"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the Internet Gateway"
  type        = map(string)
  default     = {}
}
