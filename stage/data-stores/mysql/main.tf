provider "aws" {
    region = "us-west-2"
    profile = "efiorucci"
}

resource "aws_db_instance" "db" {
    engine = "mysql"
    allocated_storage = 10
    instance_class = "db.t2.micro"
    name = "example_database"
    username = "admin"
    password = "${var.db_password}"
}

terraform {
    backend "s3" {
        bucket = "terraform-up-and-running-stage-eva"
        key = "stage/data-stores/mysql/terraform.tfstate"
        region = "us-west-2"

        dynamodb_table = "terraform-up-and-running-locks"
        encrypt = true
        profile = "efiorucci"
    }
}
