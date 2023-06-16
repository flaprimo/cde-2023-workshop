locals {
  student_sac_roles = [
    "roles/storage.admin",
    "roles/bigquery.admin",
    "roles/pubsub.admin",
    "roles/workflows.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/eventarc.admin",
    "roles/iam.serviceAccountUser",
    "roles/viewer",
    # "roles/compute.osLogin",
    # "roles/iap.tunnelResourceAccessor"
  ]
  student_roles = [
    "roles/viewer",
    "roles/storage.admin",
    "roles/bigquery.dataViewer"
  ]
}

# Create bucket for storing terraform state
resource "google_storage_bucket" "student_gcs_tf" {
  name                        = "${var.prefix}-${var.student.name}-tfstate"
  project                     = var.project_id
  location                    = var.location
  uniform_bucket_level_access = true
}

# Create sac for terraform use by students
resource "google_service_account" "student_sac_tf" {
  account_id   = "${var.prefix}-${var.student.name}-tf"
  project      = var.project_id
  display_name = "Student Service Account for Terraform - ${var.student.name}"
}

# Assign roles to student service accounts
resource "google_project_iam_member" "student_prj_roles" {
  for_each = toset(local.student_sac_roles)

  project = var.project_id
  role    = each.key
  member  = google_service_account.student_sac_tf.member
}

# Assign roles to student accounts
resource "google_project_iam_member" "student_principal_prj_roles" {
  for_each = toset(local.student_roles)

  project = var.project_id
  role    = each.key
  member  = "user:${var.student.email}"
}

# Assign roles to users for SAC impersonation
resource "google_service_account_iam_binding" "student_sac_roles_sacuser" {
  service_account_id = google_service_account.student_sac_tf.name
  role               = "roles/iam.serviceAccountUser"

  members = [
    "user:${var.admin_email}",
    "user:${var.student.email}",
  ]
}

resource "google_service_account_iam_binding" "student_sac_roles_tokencreator" {
  service_account_id = google_service_account.student_sac_tf.name
  role               = "roles/iam.serviceAccountTokenCreator"

  members = [
    "user:${var.admin_email}",
    "user:${var.student.email}",
  ]
}
