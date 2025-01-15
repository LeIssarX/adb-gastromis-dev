
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.15.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.0.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.21.0"
    }
	github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}


provider "azurerm" {
  features {}
  subscription_id = "7b7e2e40-106e-4d12-adea-7099ed5090bc"
}

provider "databricks" {
  host  = "https://adb-1769591663561658.18.azuredatabricks.net/"
  token = "<Replace with your Databricks workspace token>"
}

provider "github" {
  token = "<Replace with your GitHub token>"  
}
