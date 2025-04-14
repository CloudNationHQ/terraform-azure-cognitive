module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.24"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "northeurope"
    }
  }
}

module "cognitiveservices" {
  source  = "cloudnationhq/cognitive/azure"
  version = "~> 0.1"

  naming = local.naming

  account = {
    name           = module.naming.cognitive_account.name_unique
    resource_group = module.rg.groups.demo.name
    location       = module.rg.groups.demo.location
    sku_name       = "S0"
    kind           = "OpenAI"

    deployments = {
      gpt-4o = {
        model = {
          format  = "OpenAI"
          name    = "gpt-4o"
          version = "2024-08-06"
        }
        sku = {
          name     = "DataZoneStandard"
          capacity = 100
        }
      }
    }
  }
}
