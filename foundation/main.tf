locals {
  students = jsondecode(file("${path.module}/student_list.json"))

  apis = [
    "pubsub.googleapis.com",
    "iam.googleapis.com",
    "eventarc.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "workflows.googleapis.com",
  ]
}

resource "google_project_service" "student_apis" {
  for_each = toset(local.apis)

  project = var.project_id
  service = each.key
}

module "student_resources" {
  for_each = local.students

  source     = "./student"
  prefix     = "cde2023"
  project_id = var.project_id
  location   = var.location
  student = {
    name : each.key
    email : each.value
  }
  admin_email = "flavio.primo@bip-group.com"

  depends_on = [google_project_service.student_apis]
}
