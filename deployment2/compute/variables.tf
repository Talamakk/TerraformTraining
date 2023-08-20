variable "instances" {
  description = "VMs instances quantity"
  type        = number
  default     = 2
}

variable "region" {
  description = "Region name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "rg_name" {
  description = "Resource group name"
  type        = string
}

variable "subnet_id" {
  description = "Created subnet ID"
  type        = string
}

variable "vm_password" {
  description = "Password to VMs"
  type        = string
}

variable "blob_uri" {
  description = "URI to the script"
  type        = string
}