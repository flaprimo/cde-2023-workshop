variable "location" {
  type        = string
  description = "location for creating the resources"
}

variable "project_id" {
  type        = string
  description = "project for creating the resources"
}

variable "student" {
  type = object({
    name  = string
    email = string
  })
  description = "student for creating the resources"
}

variable "admin_email" {
  type        = string
  description = "admin for creating the resources"
}

variable "prefix" {
  type        = string
  description = "prefix for resources"
}
