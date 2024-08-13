variable "location" {
  description = "Location of the resources"
  type        = string
}

variable "naming_prefix" {
  description = "Prefix to be used in the naming of the resources."
  type        = string
}

variable "virtual_network" {
  description = "Object containing the virtual network and subnets properties."
  type = object({
    address_space = string
    subnets = list(object({
      name = string
      cidr = string
      endpoint_type = optional(string, null)
    }))
  })
}

variable "virtual_machine" {
  description = "Object containing the virtual machine properties."
  type = list(object({
    name = string
    instances = number
    subnet_name = string
  }))
}

variable "database" {
  description = "Object containing the database server properties."
  type = object({
    server_name = string
    database_name = string
  })
}