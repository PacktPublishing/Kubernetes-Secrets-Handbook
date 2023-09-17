resource "google_secret_manager_secret" "ksm_secret" {
  secret_id = "ksm-secret"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
      replicas {
        location = "us-east1"
      }
    }
  }
  project = var.project_id
}

resource "google_secret_manager_secret_version" "ksm_secret_version" {
  secret = google_secret_manager_secret.ksm_secret.id

  secret_data = "secret-data"
}

resource "google_service_account" "ksm_service_account" {
  account_id   = "read-secrets-service-account"
}

resource "google_secret_manager_secret_iam_binding" "ksm_secret_reader" {
  role   = "roles/secretmanager.secretAccessor"
  secret_id = google_secret_manager_secret.ksm_secret.id
  members = [
    "serviceAccount:${google_service_account.ksm_service_account.email}"
  ]
}

resource "google_service_account_iam_binding" "ksm_secret_reader_sa_binding" {
  service_account_id = google_service_account.ksm_service_account.id
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[default/read-secret]",
  ]
}
