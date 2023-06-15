locals {
  workflows_path = "${path.module}/workflows"
  workflows = {
    "main" : file("${local.workflows_path}/main.yaml"),
    "bqimport" : file("${local.workflows_path}/bq_import.yaml"),
    "bqexport" : file("${local.workflows_path}/bq_export.yaml")
  }
  roles_sac_workflow = [
    "roles/bigquery.dataEditor",
    "roles/storage.objectEditor",
    "roles/workflows.invoker"
  ]
  roles_sac_eventarc = [
    "roles/pubsub.subscriber",
    "roles/workflows.invoker"
  ]
}

# PUBSUB
resource "google_pubsub_topic" "topic" {
  name    = "${var.prefix}-topic"
  project = var.project_id
}

# BIGQUERY
resource "google_bigquery_dataset" "dataset" {
  dataset_id = "${replace(var.prefix, "-", "_")}_dataset"
  location   = var.location
  project    = var.project_id
}

# GCS
resource "google_storage_bucket" "bucket-import" {
  name                        = "${var.prefix}-bucket-import"
  project                     = var.project_id
  location                    = var.location
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "bucket-export" {
  name                        = "${var.prefix}-bucket-export"
  project                     = var.project_id
  location                    = var.location
  uniform_bucket_level_access = true
}

# GCS NOTIFICATION
resource "google_storage_notification" "notification" {
  bucket         = google_storage_bucket.bucket-import.name
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.topic.id
  event_types    = ["OBJECT_FINALIZE", "OBJECT_METADATA_UPDATE"]

  depends_on = [google_pubsub_topic_iam_binding.roles_sac_gcs]
}

resource "google_pubsub_topic_iam_binding" "roles_sac_gcs" {
  topic   = google_pubsub_topic.topic.id
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${data.google_storage_project_service_account.sac_gcs.email_address}"]
}

data "google_storage_project_service_account" "sac_gcs" {
  project = var.project_id
}

# WORKFLOWS
resource "google_service_account" "sac_workflow" {
  account_id = "${var.prefix}-sac-workflow"
  project    = var.project_id
}

resource "google_project_iam_member" "roles_sac_workflow" {
  for_each = toset(local.roles_sac_workflow)

  project = var.project_id
  role    = each.key
  member  = google_service_account.sac_workflow.member
}

resource "google_workflows_workflow" "workflows" {
  for_each = local.workflows

  name            = "${var.prefix}-wf-${each.key}"
  region          = var.location
  project         = var.project_id
  service_account = google_service_account.sac_workflow.id
  source_contents = each.value
}

# EVENTARC
resource "google_service_account" "sac_eventarc" {
  account_id   = "${var.prefix}-sac-eventarc"
  display_name = "Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "roles_sac_eventarc" {
  for_each = toset(local.roles_sac_eventarc)

  project = var.project_id
  role    = each.key
  member  = google_service_account.sac_workflow.member
}

resource "google_eventarc_trigger" "eventarc" {
  name     = "${var.prefix}-eventarc"
  location = var.location
  project  = var.project_id
  destination {
    workflow = google_workflows_workflow.workflows["main"].id
  }
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }
  service_account = google_service_account.sac_eventarc.email
  transport {
    pubsub {
      topic = google_pubsub_topic.topic.id
    }
  }
}
