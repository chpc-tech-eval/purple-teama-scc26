terraform {
  required_version = ">= 1.9.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "3.4.0"
    }
  }
}

# Each team member authenticates with their OWN local clouds.yaml
# (~/.config/openstack/clouds.yaml). No credentials live in this repository.
provider "openstack" {
  cloud = var.cloud
}
