data "google_container_engine_versions" "gke_version" {
  location = var.region
  version_prefix = "1.27."
}

resource "google_container_cluster" "eks_cluster" {
  name     = "secrets-cluster"
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  database_encryption {
    key_name = google_kms_crypto_key.ksm_secret_key.id
    state = "ENCRYPTED"
  }
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    disk_size_gb = 10
    machine_type = "n1-standard-1"
  }

  workload_identity_config {
    workload_pool = "kube-secrets-book.svc.id.goog"
  }
  lifecycle {
    ignore_changes = all    

  }
  depends_on = [ 
    google_kms_crypto_key_iam_binding.ksm_secret_key_encdec
   ]
}

resource "google_container_node_pool" "primary_nodes" {
  name       = google_container_cluster.eks_cluster.name
  location   = var.region
  cluster    = google_container_cluster.eks_cluster.name
  
  version = data.google_container_engine_versions.gke_version.release_channel_latest_version["STABLE"]
  node_count = 1
  
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke"]
    disk_size_gb = 10
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
  lifecycle {
    ignore_changes = all    

  }
}

