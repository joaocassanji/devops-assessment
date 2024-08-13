
# Azure Virtual Machine with Network Interface and NGINX Extension

This Terraform configuration creates a set of resources in Azure, specifically a Network Interface, a Linux Virtual Machine, and a Virtual Machine Extension for installing and configuring NGINX. Below is an explanation of each resource and how they work together.

## Resource Definitions

### 1. azurerm_network_interface (NIC)

The `azurerm_network_interface` resource creates a network interface in Azure.

```bash
resource "azurerm_network_interface" "nic" {
  count = var.instances
  name                = "${var.name}-nic-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration { 
      name                          = "default"
      subnet_id                     = var.subnet_id
      private_ip_address_allocation = "Dynamic"
      private_ip_address_version    = "IPv4"
  }
}
```

- **count:** The number of network interfaces to create, based on the variable `var.instances`.
- **name:** Each NIC is named using the pattern `${var.name}-nic-${count.index}`.
- **location:** The Azure region where the NIC will be created.
- **resource_group_name:** The resource group in which the NIC will be created.
- **ip_configuration:** Configures the IP settings, including subnet association and dynamic IP allocation.

### 2. azurerm_linux_virtual_machine (Linux VM)

The `azurerm_linux_virtual_machine` resource creates a Linux virtual machine in Azure.

```bash
resource "azurerm_linux_virtual_machine" "linux_vm" {
  count = var.instances
  name                            = "${var.name}-vm-${count.index}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  os_disk {
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
  }

  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = var.image.version
  }

  boot_diagnostics {
    
  }
}
```

- **count:** The number of virtual machines to create, based on the variable `var.instances`.
- **name:** Each VM is named using the pattern `${var.name}-vm-${count.index}`.
- **resource_group_name:** The resource group in which the VM will be created.
- **location:** The Azure region where the VM will be created.
- **size:** Specifies the size of the VM (e.g., Standard_B2s).
- **admin_username/admin_password:** Specifies the administrator username and password.
- **network_interface_ids:** Associates the VM with a network interface created earlier.
- **os_disk:** Configures the OS disk, including caching and storage account type.
- **source_image_reference:** Specifies the image to use for the VM, including publisher, offer, SKU, and version.

### 3. azurerm_virtual_machine_extension (VM Extension)

The `azurerm_virtual_machine_extension` resource installs and configures NGINX on the Linux virtual machine.

```bash
resource "azurerm_virtual_machine_extension" "vm_extension" {
  count = var.instances
  name = "Nginx"
  virtual_machine_id = azurerm_linux_virtual_machine.linux_vm[count.index].id
  publisher = "Microsoft.Azure.Extensions"
  type = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
 {
  "commandToExecute": "sudo apt-get update && sudo apt-get install nginx -y && echo "Hello World from $(hostname)" > /var/www/html/index.html && sudo systemctl restart nginx"
 }
SETTINGS

}
```

- **count:** The number of VM extensions to create, based on the variable `var.instances`.
- **name:** The name of the extension, in this case, `Nginx`.
- **virtual_machine_id:** The ID of the VM to which this extension will be applied.
- **publisher/type/type_handler_version:** Specifies the extension publisher, type, and version.
- **settings:** A JSON block containing the commands to execute on the VM. This installs NGINX, creates a simple "Hello World" page, and restarts NGINX.

## Usage

To use this Terraform module, you can call it from your main Terraform configuration as follows:

```bash
module "linux_vm_with_nginx" {
  source              = "./path_to_module"
  instances           = 2
  name                = "my-linux-vm"
  location            = "East US"
  resource_group_name = "my-resource-group"
  subnet_id           = "subnet-id"
}
```

Replace `"./path_to_module"` with the path where this module is located. Adjust the variables as needed for your environment.

This will create the specified number of Linux VMs with attached network interfaces and NGINX installed.
