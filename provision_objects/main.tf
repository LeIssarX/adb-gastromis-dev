# Create dev envirnment
resource "databricks_catalog" "dev_catalog" {
  name = "dev"
}

resource "databricks_schema" "dev_bronze" {
  name         = "bronze"
  catalog_name = databricks_catalog.dev_catalog.name
}

resource "databricks_schema" "dev_silver" {
  name         = "silver"
  catalog_name = databricks_catalog.dev_catalog.name
}

resource "databricks_schema" "dev_gold" {
  name         = "gold"
  catalog_name = databricks_catalog.dev_catalog.name
}

# Create prod envirnment
resource "databricks_catalog" "prod_catalog" {
  name = "prod"
}

resource "databricks_schema" "prod_bronze" {
  name         = "bronze"
  catalog_name = databricks_catalog.prod_catalog.name
}

resource "databricks_schema" "prod_silver" {
  name         = "silver"
  catalog_name = databricks_catalog.prod_catalog.name
}

resource "databricks_schema" "prod_gold" {
  name         = "gold"
  catalog_name = databricks_catalog.prod_catalog.name
}

# Provision SQL Warehouse
resource "databricks_sql_endpoint" "gmis_sql_warehouse" {
  name                = "gmis_warehouse"
  cluster_size        = "Small"
  auto_stop_mins      = 15
  enable_serverless_compute = true
  max_num_clusters    = 1
}

# Provision a cluster with Event Hub package
resource "databricks_cluster" "general_purpose_cluster" {
  cluster_name            = "gmis-cluster"
  spark_version           = "14.0.x-scala2.12"
  node_type_id            = "Standard_DS3_v2" 
  autotermination_minutes = 20
  autoscale {
    min_workers = 1
    max_workers = 3
  }

  library {
    maven {
      coordinates = "com.microsoft.azure:azure-eventhubs-spark_2.12:2.3.22"
    }
  }
}

# Create a databricks job, exmple running a code using prophet
resource "databricks_job" "gmis_test_job" {
    name = "gmis_test_job"
    timeout_seconds = 3600
    max_retries = 1
    max_concurrent_runs = 1
	
	# Here we can choose 
    new_cluster  {
        num_workers   = 1
        spark_version = "14.0.x-scala2.12"
		node_type_id  = "Standard_DS3_v2"
    }

    notebook_task {
        notebook_path = "/Workspace/test"
    }

    library {
        pypi {
            package = "fbprophet==0.6"
        }
    }

    email_notifications {
        no_alert_for_skipped_runs = true
		on_failure = ["issar.arab@ruhr.agency"]
    }
	
}

# Attach Git to the workspace
resource "databricks_repo" "attach_github_repo" {
  url = "https://github.com/LeIssarX/adb-gastromis-dev.git"
  provider = github
}