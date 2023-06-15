terraform {
  backend "gcs" {
    bucket                      = "cde2023-shared-tfstate"
    impersonate_service_account = "cde2023-shared-terraform@workshop-master-cloud.iam.gserviceaccount.com"
  }
  required_providers {
    google = {
      version = ">= 4.69.0"
    }
    google-beta = {
      version = ">= 4.69.0"
    }
  }
}
provider "google" {
  impersonate_service_account = "cde2023-shared-terraform@workshop-master-cloud.iam.gserviceaccount.com"
}
provider "google-beta" {
  impersonate_service_account = "cde2023-shared-terraform@workshop-master-cloud.iam.gserviceaccount.com"
}
