variable "prefix" {
  type        = string
  default     = "cde2023-fprimo"
  description = "location for creating the resources"
}

variable "location" {
  type        = string
  default     = "europe-west1"
  description = "location for creating the resources"
}

variable "project_id" {
  type        = string
  default     = "workshop-master-cloud"
  description = "project for creating the resources"
}
