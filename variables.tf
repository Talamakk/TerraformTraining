variable "region" {
  description = "Region name"
  type        = string
  default     = "polandcentral"

  validation {
    condition = contains(["francecentral",
      "francesouth",
      "germanynorth",
      "germanywestcentral",
      "northeurope",
      "norwayeast",
      "norwaywest",
      "polandcentral",
      "swedencentral",
      "swedensouth",
      "switzerlandnorth",
      "switzerlandwest",
      "uksouth",
      "ukwest",
      "westeurope",
      "germanycentral",
      "germanynortheast"
    ], var.region)

    error_message = "Specified region is not allowed or does not exist. Please select European region."
  }
}

variable "env" {
  description = "Environment name"
  type        = string

  validation {
    condition = anytrue([
      var.env == "dev",
      var.env == "uat",
      var.env == "prod"
    ])
    error_message = "Specified env does not exist. Allowed values are: dev, uat, prod."
  }
}

variable "nsg_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  description = "Values for NSG rules"
}

variable "instances" {
  description = "VMs instances quantity"
  type        = number
  default     = 2
}
