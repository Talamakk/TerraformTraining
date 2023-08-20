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