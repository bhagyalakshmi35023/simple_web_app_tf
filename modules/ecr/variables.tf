variable "name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "MUTABLE or IMMUTABLE — use IMMUTABLE in production to prevent tag overwrites"
  type        = string
}

variable "scan_on_push" {
  description = "Scan images for vulnerabilities on every push"
  type        = bool
}

variable "max_image_count" {
  description = "Number of images to retain — older images are expired automatically"
  type        = number
}

variable "lifecycle_policy_rule_priority" {
  description = "Priority of the lifecycle policy rule (lower number = higher priority)"
  type        = number
}

variable "lifecycle_tag_status" {
  description = "Tag status to apply the lifecycle rule to: tagged, untagged, or any"
  type        = string
}

variable "lifecycle_count_type" {
  description = "How to count images for expiry: imageCountMoreThan or sinceImagePushed"
  type        = string
}

variable "lifecycle_action_type" {
  description = "Action to take on matched images: expire"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the ECR repository"
  type        = map(string)
  default     = {}
}
