resource "google_storage_bucket" "student_gcs_tf" {
  name                        = "${var.prefix}-test-bucket"
  project                     = var.project_id
  location                    = var.location
  uniform_bucket_level_access = true
}
