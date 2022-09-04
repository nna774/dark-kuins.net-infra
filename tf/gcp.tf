terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.34.0"
    }
  }
   backend "gcs" {
    bucket  = "nna-tf-state"
  }
}

provider "google" {
  project     = "united-crane-800"
  region      = "asia-northeast2"
}
