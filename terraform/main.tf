terraform {
  required_version = ">= 1.0"
  backend "local" {} # Can change from "local" to "gcs" (for google) or "s3" (for aws), if you would like to preserve your tf-state online
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region

}

# Data Lake Bucket
# Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
resource "google_storage_bucket" "data-lake-bucket" {
  name     = "${var.project}_${local.data_lake_bucket}" # Concatenating DL bucket & Project name for unique naming
  location = var.region

  # Optional, but recommended settings:
  storage_class               = var.storage_class
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 60 // days
    }
  }

  force_destroy = true
}


#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset
resource "google_bigquery_dataset" "gitanalytics_de" {
  dataset_id = var.bq_dataset
  project    = var.project
  location   = var.region
}

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_table

resource "google_bigquery_table" "gitanalytics_raw_data" {
  dataset_id = google_bigquery_dataset.gitanalytics_de.dataset_id
  table_id   = "gitanalytics_raw_data"

  schema              = <<EOF
  [
    {
      "name": "id",
      "type" : "STRING",
      "mode" : "NULLABLE",
      "description": "Unique event ID of GIT"
    },
    {
      "name": "type",
      "type" : "STRING",
      "mode" : "NULLABLE",
      "description": "Type of Git events"
    },
    {
      "name": "created_at",
      "type" : "TIMESTAMP",
      "mode" : "NULLABLE",
      "description": "Timestamp when the event happened"
    },
    {
      "name": "actor_id",
      "type" : "STRING",
      "mode" : "NULLABLE",
      "description": "Unique id of an actor"
    },
    {
      "name": "actor_login",
      "type" : "STRING",
      "mode" : "NULLABLE",
      "description": "login information of an actor"
    },
    {
      "name": "repo_id",
      "type" : "STRING",
      "mode" : "NULLABLE",
      "description": "ID of the GIT repository"
    },
    {
      "name": "repo_name",
      "type" : "STRING",
      "mode" : "NULLABLE",
      "description": "name of the GIT repository"
    },
    {
      "name": "payload_size",
      "type": "Integer",
      "mode": "NULLABLE",
      "description": "Size of the payload"
    },
    {
      "name": "org_present",
      "type" : "STRING",
      "mode" : "NULLABLE",
      "description": "Classifify if the repo is Organization or not"
    }
  ] 
  EOF
  deletion_protection = false #will delete the dataset with the table using terrafrom destroy command
}

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_table

resource "google_bigquery_table" "analytics_events_fact" {
  dataset_id = google_bigquery_dataset.gitanalytics_de.dataset_id
  table_id   = "analytics_events_fact"

  schema              = <<EOF
  [
    {
      "name": "event_id",
      "type" : "STRING",
      "mode" : "NULLABLE",
      "description": "Unique event ID of GIT"
    },
    {
      "name": "event_type_id",
      "type" : "STRING",
      "mode" : "NULLABLE",
      "description": "Type of Git events"
    },
    {
      "name": "actor_id",
      "type" : "STRING",
      "mode" : "NULLABLE",
      "description": "Unique id of an actor"
    },
    {
      "name": "repo_id",
      "type" : "STRING",
      "mode" : "NULLABLE",
      "description": "ID of the GIT repository"
    },
    {
      "name": "payload_size",
      "type": "Integer",
      "mode": "NULLABLE",
      "description": "Size of the payload"
    },
    {
      "name": "org_present",
      "type" : "STRING",
      "mode" : "NULLABLE",
      "description": "Classifify if the repo is Organization or not"
    },
    {
      "name": "date_id",
      "type" : "TIMESTAMP",
      "mode" : "NULLABLE",
      "description": "Timestamp when the event happened"
    }
  ] 
  EOF
  deletion_protection = false #will delete the dataset with the table using terrafrom destroy command
}

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_table

resource "google_bigquery_table" "analytics_eventtypes" {
  dataset_id = google_bigquery_dataset.gitanalytics_de.dataset_id
  table_id   = "analytics_eventtypes"

  schema              = <<EOF
  [
    {
      "name": "event_type_id",
      "type" : "STRING",
      "mode" : "NULLABLE",
      "description": "Type of Git events"
    },
    {
      "name": "event_type",
      "type" : "STRING",
      "mode" : "NULLABLE",
      "description": "Unique id of an actor"
    }
    
  ] 
  EOF
  deletion_protection = false #will delete the dataset with the table using terrafrom destroy command
}

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_table

resource "google_bigquery_table" "analytics_actors_info" {
  dataset_id = google_bigquery_dataset.gitanalytics_de.dataset_id
  table_id   = "analytics_analytics_info"

  schema              = <<EOF
  [
    {
      "name": "actor_id",
      "type" : "STRING",
      "mode" : "NULLABLE",
      "description": "Unique id of actor"
    },
    {
      "name": "actor_login",
      "type" : "STRING",
      "mode" : "NULLABLE",
      "description": "login info of actors"
    },
    {
      "name": "is_bot",
      "type" : "STRING",
      "mode" : "NULLABLE",
      "description": "Classify accont as a bot"
    }
  ] 
  EOF
  deletion_protection = false #will delete the dataset with the table using terrafrom destroy command
}

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_table

resource "google_bigquery_table" "analytics_repo_info" {
  dataset_id = google_bigquery_dataset.gitanalytics_de.dataset_id
  table_id   = "analytics_repo_info"

  schema              = <<EOF
  [
    {
      "name": "repo_id",
      "type" : "STRING",
      "mode" : "NULLABLE",
      "description": "Unique ID of the repo"
    },
    {
      "name": "repo_name",
      "type" : "STRING",
      "mode" : "NULLABLE",
      "description": "Type of Git events"
    }
  ] 
  EOF
  deletion_protection = false #will delete the dataset with the table using terrafrom destroy command
}

resource "google_bigquery_table" "dates_info" {
  dataset_id = google_bigquery_dataset.gitanalytics_de.dataset_id
  table_id   = "dates_info"

  schema              = <<EOF
  [
    {
      "name": "date_id",
      "type" : "DATE",
      "mode" : "NULLABLE",
      "description": "Date ID"
    },
    {
      "name": "date",
      "type" : "DATE",
      "mode" : "NULLABLE",
      "description": "Date"
    },
    {
      "name": "month",
      "type" : "string",
      "mode" : "NULLABLE",
      "description": "month"
    },
    {
      "name": "year",
      "type" : "string",
      "mode" : "NULLABLE",
      "description": "year"
    }
  ] 
  EOF
  deletion_protection = false #will delete the dataset with the table using terrafrom destroy command
}

