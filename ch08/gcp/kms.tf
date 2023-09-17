resource "google_kms_key_ring" "ksm_key_ring" {
  name     = "ksm-key-ring"
  location = var.region
}

resource "google_kms_crypto_key" "ksm_secret_key" {
  name = "ksm-secret-encryption"
  key_ring = google_kms_key_ring.ksm_key_ring.id
  lifecycle {
    prevent_destroy = false
    ignore_changes = all
  }
  
}

data "google_project" "project" {}

resource "google_kms_crypto_key_iam_binding" "ksm_secret_key_encdec" {
  crypto_key_id = google_kms_crypto_key.ksm_secret_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
  ]
  lifecycle {
    ignore_changes = all
  }
}
