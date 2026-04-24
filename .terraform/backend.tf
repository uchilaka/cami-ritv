terraform {
  backend "s3" {
    # Replace with your bucket name
    bucket    = var.tf_state_bucket
    key       = "cami/fly/terraform.tfstate"
    region    = "us-east-1"

    # For Tigris (Fly.io), you would set the endpoint and skip some AWS-specific checks
    endpoint                      = var.fly_aws_endpoint_url_s3
    # skip_credentials_validation = true
    # skip_metadata_api_check     = true
    # skip_region_validation      = true
    # skip_s3_checksum            = true
  }
}
