This example illustrates the default setup for Azure Cognitive Services, in its simplest form.

## Usage: default

```hcl
module "cognitiveservices" {
  source  = "cloudnationhq/cognitive/azure"
  version = "~> 0.1"

  account = {
    name           = module.naming.cognitive_account.name_unique
    resource_group = module.rg.groups.demo.name
    location       = module.rg.groups.demo.location
    kind          = "OpenAI"
    sku_name      = "S0"
  }
}
```