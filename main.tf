locals {
  region            = "us-central1"
  availability_zone = "us-central1-a"
}


resource "google_project_service" "enable_artifact_registry_api" {
  service = "artifactregistry.googleapis.com"
  project = var.project_id
}


resource "google_artifact_registry_repository" "cache" {
  provider = google-beta
  project  = var.project_id

  location      = local.region
  repository_id = "my-repo"
  description   = "Repository for storing Docker images."

  format = "DOCKER"

  cleanup_policies {
    id     = "keep-prod-release"
    action = "KEEP"

    condition {
      tag_state    = "TAGGED"
      tag_prefixes = ["prod"]
    }
  }

  cleanup_policies {
    id     = "keep-minimum-versions"
    action = "KEEP"

    most_recent_versions {
      keep_count = 5
    }
  }

  cleanup_policies {
    id     = "gc-untagged"
    action = "DELETE"

    condition {
      tag_state  = "UNTAGGED"
      older_than = "2592000s"
    }
  }

  depends_on = [
    google_project_service.enable_artifact_registry_api
  ]
}