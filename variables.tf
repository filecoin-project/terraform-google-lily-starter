# REQUIRED PARAMETERS

variable "project_id" {
  description = "The GCP project ID where Lily will be deployed."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "The project_id must be a string of alphanumeric or hyphens, between 6-30 characters in length."
  }
}

variable "zone" {
  description = "The zone to deploy the Lily instance to. A subset of a GCP region."
  type        = string
}

variable "instance_name" {
  description = "The name for the VM instance to deploy Lily onto."
  type        = string
}

variable "instances_per_project" {
  description = "The number of Lily instances to deploy to your GCP project."
  type        = number
  default     = 1
}

# OPTIONAL PARAMETERS

variable "network" {
  description = "The Filecoin network for the Lily build directive."
  type        = string
  default     = "mainnet"
}

variable "release" {
  description = "The Lily release to build."
  type        = string
  default     = "master"
}
