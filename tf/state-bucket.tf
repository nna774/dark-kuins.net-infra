resource "google_storage_bucket" "state-bucket" {
  name          = "nna-tf-state"
  location      = "asia-northeast2"
}
