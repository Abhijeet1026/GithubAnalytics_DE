locals {
  data_lake_bucket = "github_analytics"
}

variable "project" {
  description = "Your GCP project ID"
  default     = "dataengineering1-433721"
}

variable "region" {
  description = "Region for GCP resources. Choose as per your location: https://cloud.google.com/about/locations"
  default     = "us-west1"
  type        = string
}

variable "storage_class" {
  description = "Storage class type for your bucket. Check official docs for more info."
  default     = "STANDARD"
}

variable "bq_dataset" {
  description = "BigQuery Dataset:  data (from GCS) will be written to"
  type        = string
  default     = "gitanalytics_de"
}