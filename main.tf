variable "name" {
  type = "string"
}

variable "location" {
  type = "string"
}
variable "resource_group" {
  type = "string"
}

variable "tags" {
  type = "map"
}


###### ROOT module example:

# module "storage" {
#   source   = "./modules/storage"
#   name     = "${replace("${azurerm_resource_group.this.name}", "-", "")}sa"
#   location = "${azurerm_resource_group.this.location}"
#   resource_group = "${azurerm_resource_group.this.name}"


#   tags = "${merge(
#     "${var.common_tags}",
#     map(
#       "Stage", "Development"
#     )
#   )}"

# }


###### This module code
resource "azurerm_storage_account" "this" {
  name                     = "${var.name}"
  resource_group_name      = "${var.resource_group}"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = "${var.tags}"
}

resource "azurerm_storage_share" "file_share" {
  count                = "${length(var.file_shares_names)}"
  name                 = "${var.file_shares_names[count.index]}"
  quota                = "${var.file_shares_quota[count.index]}"
  resource_group_name  = "${azurerm_resource_group.this.name}"
  storage_account_name = "${azurerm_storage_account.this.name}"
  depends_on           = ["azurerm_storage_account.this"]
}

resource "azurerm_storage_container" "this" {
  name                  = "${azurerm_storage_account.this.name}-container"
  resource_group_name   = "${azurerm_resource_group.this.name}"
  storage_account_name  = "${azurerm_storage_account.this.name}"
  container_access_type = "private"
}

resource "azurerm_storage_blob" "file_share" {
  count                  = "${length(var.file_shares_names)}"
  name                   = "${var.file_shares_names[count.index]}"
  resource_group_name    = "${azurerm_resource_group.this.name}"
  storage_account_name   = "${azurerm_storage_account.this.name}"
  storage_container_name = "${azurerm_storage_container.this.name}"

  type = "page"
  # size = 

  depends_on = ["azurerm_storage_account.this"]
}
