region = "us-east-1"

db_config = {
  dbpostgres = {
    engine = "postgres",
    engine_version = "15.7",
    instance_class = "db.t3.micro",
    storage_type = "gp3",
    allocated_storage = "20"
    performance_insights_enabled = true,
    backup_retention_period = "7",
    deletion_protection = false,
    publicly_accessible = false,
    multi_az = true
    max_allocated_storage= "1000"
    }
}