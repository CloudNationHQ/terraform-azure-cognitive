This example details OpenAI deployments with model configurations and blocklists.

## Usage: deployments

```hcl
module "cognitiveservices" {
  source  = "cloudnationhq/cognitive/azure"
  version = "~> 0.1"

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
    
    blocklists = {
      harmful_content = {
        name        = "harmful-content-blocklist"
        description = "Blocks harmful content including hate speech and violence"
      },
      personal_info = {
        name        = "personal-info-blocklist"
        description = "Blocks personal identifiable information" 
      },
      custom_terms = {
        description = "Custom terms and phrases to block"
      }
    }
  }
}