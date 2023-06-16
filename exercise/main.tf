locals {
  workflows_path = "${path.module}/workflows"
  workflows = {
    "main" : file("${local.workflows_path}/main.yaml"),
    "bqimport" : file("${local.workflows_path}/bq_import.yaml"),
    "bqexport" : file("${local.workflows_path}/bq_export.yaml")
  }
  roles_sac_workflow = [
    "roles/logging.logWriter",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/storage.objectAdmin",
    "roles/workflows.invoker"
  ]
  roles_sac_eventarc = [
    "roles/pubsub.subscriber",
    "roles/workflows.invoker"
  ]
}
