location      = "eastus"
naming_prefix = "vlz"

virtual_network = {
  address_space = "10.0.0.0/16"
  subnets = [
    {
      name = "application"
      cidr = "10.0.1.0/24"
    },
    {
      name = "web"
      cidr = "10.0.2.0/24"
    },
    {
      name = "database"
      cidr = "10.0.3.0/24"
    }
  ]
}

virtual_machine = [ 
    {
        name = "application"
        instances = 1
        subnet_name = "application"
    },
    {
        name = "web"
        instances = 2
        subnet_name = "web"
    },
]

database = {
  server_name = "dbservervlzassess"
  database_name = "database"
}