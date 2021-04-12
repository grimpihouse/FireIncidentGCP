locals {
    timestamp   = formatdate("YYMMDDhhmmss", timestamp())
}

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  version = "3.5.0"

  credentials = file("../fireincident-310410-89793da415ac.json")

  project = "fireincident-310410"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = "DataSF"
  friendly_name               = "DataSF"
  description                 = ""
  location                    = "US"

  labels = {
    env = "default"
  }
}

resource "google_storage_bucket" "datasfcodefunctions" {
  name = "datasfcodefunctions"
}

data "archive_file" "DataSF" {
 type        = "zip"
 source_dir = "../${path.root}/functions"
 output_path = "../${path.root}/DataSF.zip"
}

resource "google_storage_bucket_object" "DataSF" {
 name   = "${local.timestamp}.zip"
 bucket = google_storage_bucket.datasfcodefunctions.name
 source = "../${path.root}/DataSF.zip"
}

resource "google_cloudfunctions_function" "load_daily" {
  name        = "load_daily"
  description = ""
  runtime     = "python39"
  entry_point = "load_daily"
  project = "fireincident-310410"
  region = "us-central1"
  available_memory_mb   = 256
  timeout = 480
  max_instances= 1
  service_account_email = "fireincident-310410@appspot.gserviceaccount.com"
  source_archive_bucket = google_storage_bucket.datasfcodefunctions.name
  source_archive_object = google_storage_bucket_object.DataSF.name
  trigger_http          = true
}

resource "google_cloudfunctions_function" "load_history" {
  name        = "load_history"
  description = ""
  runtime     = "python39"
  entry_point = "load"
  project = "fireincident-310410"
  region = "us-central1"
  available_memory_mb   = 2048
  timeout = 480
  service_account_email = "fireincident-310410@appspot.gserviceaccount.com"
  source_archive_bucket = google_storage_bucket.datasfcodefunctions.name
  source_archive_object = google_storage_bucket_object.DataSF.name
  trigger_http          = true  
}
