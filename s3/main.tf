provider "aws" {
    profile = "efiorucci"
    region = "us-west-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-and-running-stage-eva"

  versioning {
    enabled = true
  }

  lifecycle {
      prevent_destroy = true
  }

  server_side_encryption_configuration {
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
  }
}
resource "aws_dynamodb_table" "terraform_locks" {
    name = "terraform-up-and-running-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}

terraform {
    backend "s3" {
        bucket = "terraform-up-and-running-stage-eva"
        key = "global/s3/terraform.tfstate"
        region = "us-west-2"

        dynamodb_table = "terraform-up-and-running-locks"
        encrypt = true
        profile = "efiorucci"
    }
}

