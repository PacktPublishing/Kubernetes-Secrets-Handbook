variable "region" {
  type        = string
  default     = "eu-west-1"
}

variable "eks_version" {
  type    = string
  default = "1.24"
}

variable "cluster_name" {
  type = string
  default = "eks-ksm-cluster"
}

variable "availability_zones" {
  type = list(string)
  default = [ 
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c"
  ]
}