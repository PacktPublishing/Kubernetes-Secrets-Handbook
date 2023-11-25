variable "project_id" {
  type    = string
  default = "project-id"
}

variable "region" {
  default     = "us-central1"
  description = "The central"
}

variable "gke_username" {
  default     = "gke_username"
  description = "gke_username"
}

variable "gke_password" {
  default     = "gke_password"
  description = "gke_password"
}

variable "gke_num_nodes" {
  default     = 1
  description = "number of gke nodes"
}