terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.107.0"
    }
  }

  backend "local" {
  }
}

provider "azurerm" {
  features {}
}

module "rg" {
  source        = "./modules/resource-group"
  naming_prefix = var.naming_prefix
  location      = var.location
}

module "vnet" {
  source              = "./modules/virtual-network"
  naming_prefix       = var.naming_prefix
  location            = var.location
  resource_group_name = module.rg.name
  address_space       = var.virtual_network.address_space
  subnets = var.virtual_network.subnets
}

module "vm" {
  source = "./modules/linux-virtual-machine"
  count = length(var.virtual_machine)
  name = var.virtual_machine[count.index].name
  instances = var.virtual_machine[count.index].instances
  resource_group_name = module.rg.name
  location = var.location
  subnet_id = module.vnet.subnets[var.virtual_machine[count.index].subnet_name]
}

module "nsg" {
  source = "./modules/network-security-group"
  name = "default-nsg"
  resource_group_name = module.rg.name
  location = var.location
  vnet_address_space = var.virtual_network.address_space
  web_subnet_cidr = [for snet in var.virtual_network.subnets : snet.cidr if snet.name == "web"][0]
}

module "nsg_association" {
  source = "./modules/network-security-group-association"
  network_security_group_id = module.nsg.id
  subnets_id = values(module.vnet.subnets)
}

module "lb" {
  source = "./modules/load-balancer"
  name = "web-lb"
  resource_group_name = module.rg.name
  location = var.location
  virtual_network_id = module.vnet.id
  subnet_id = module.vnet.subnets.web
  backend_nics_count = [for vm in var.virtual_machine : vm.instances if vm.name == "web"][0]
  backend_nics = [for nic_id in flatten(module.vm.*.nic_id) : nic_id if strcontains(nic_id, "web-nic")]
}

module "database" {
  source = "./modules/mysql-server"
  location = var.location
  resource_group_name = module.rg.name
  db_server_name = var.database.server_name
  db_name = var.database.database_name
  subnet_id = module.vnet.subnets.database
}