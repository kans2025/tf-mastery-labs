resource "google_storage_bucket_iam_binding" "public_test" {
  bucket  = "YOUR_BUCKET"
  role    = "roles/storage.objectViewer"
  members = ["allUsers"]
}