locals {
  name = "todo"
  location    = "centralindia"
  environment = var.environment
resource_prefix = "${local.name}-${local.environment}"

  common_tags = {
    "ManagedBy"   = "Terraform"
    "Owner"       = "TodoAppTeam"
    "Environment" = "dev"
    project      = "TodoApp"
  }
}


module "rg" {
  source      = "../../modules/azurerm_resource_group"
  rg_name     = "rg-${local.resource_prefix}"
  rg_location = local.location
  rg_tags     = local.common_tags
}

module "acr" {
  depends_on = [module.rg]
  source     = "../../modules/azurerm_container_registry"
  acr_name   = "acrdevtodoacr"
  rg_name     = module.rg.rg_name
  location   = local.location
  tags       = local.common_tags
}

# module "sql_server" {
#   depends_on      = [module.rg]
#   source          = "../../modules/azurerm_sql_server"
#   sql_server_name = "sql-dev-todoapp-0153"
#   rg_name         = "rg-dev-todoapp-01"
#   location        = "centralindia"
#   admin_username  = "devopsadmin"
#   admin_password  = "P@ssw01rd@123"
#   tags            = local.common_tags
# }

# module "sql_db" {
#   depends_on  = [module.sql_server]
#   source      = "../../modules/azurerm_sql_database"
#   sql_db_name = "sqldb-dev-todoapp"
#   server_id   = module.sql_server.server_id
#   max_size_gb = "2"
#   tags        = local.common_tags
# }

module "aks" {
  depends_on = [module.rg]
  source     = "../../modules/azurerm_kubernetes_cluster"
  aks_name   = "aks-${local.resource_prefix}"
  location   = local.location
  rg_name    = module.rg.rg_name
  dns_prefix = "aks-${local.resource_prefix}"
  tags       = local.common_tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.principal_id
}


# module "pip" {
#   source   = "../../modules/azurerm_public_ip"
#   depends_on = [ module.rg ]
#   pip_name = "pip-dev-todoapp"
#   rg_name  = "rg-dev-todoapp-01"
#   location = "centralindia"
#   sku      = "Standard"
#   tags     = local.common_tags
# }

# module "ui_webapp" {
#   depends_on       = [module.rg]
#   source           = "../../modules/azurerm_web_app"
#   runtime_stack    = "node"
#   enable_db        = false
#   app_name         = "dev-todoapp-ui-web-kam"
#   app_service_plan = "dev-todoapp-ui-asp-kam"
#   rg_name          = "rg-dev-todoapp-01"
#   location         = "Central India"

#   tags = local.common_tags
# }

# module "backned_webapp" {
#   depends_on         = [module.sql_db]
#   source             = "../../modules/azurerm_web_app"
#   runtime_stack      = "python"
#   enable_db          = true
#   app_name           = "dev-todoapp-backend-web-kam"
#   app_service_plan   = "dev-todoapp-backend-asp-kam"
#   rg_name            = "rg-dev-todoapp-01"
#   location           = "Central India"
#   sql_server_name    = "sql-dev-todoapp-0153"
#   sql_admin_username = "devopsadmin"
#   sql_admin_password = "P@ssw01rd@123"
#   sql_database_name  = "sqldb-dev-todoapp"

#   tags = local.common_tags
# }
