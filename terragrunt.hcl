locals {
  region  = "us-east-1"
  project = "alex-dev-machine"
  bucket  = "${local.project}-tf-state"
}

inputs = {
  region  = local.region
  project = local.project
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = local.bucket
    key            = "terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "${local.project}-lock"
  }
}

terraform {
  extra_arguments "conditional_vars" {
    commands = [
      "apply",
      "import",
      "init",
      "plan",
      "push",
      "refresh",
      "state"
    ]

    required_var_files = [
      "./tfvars/terraform.tfvars"
    ]
  }

  after_hook "upload_vars" {
    commands     = ["apply"]
    execute      = ["make", "push_vars"]
    run_on_error = false
  }
}
