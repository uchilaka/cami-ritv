terraform {
  required_providers {
    fly = {
      source  = "stategraph/fly"
      version = "~> 0.2.3"
    }
  }
}
provider "fly" {}
