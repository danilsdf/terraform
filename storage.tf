terraform {
    required_version = ">= 0.12"
    backend "s3" {
      bucket = "library-backet"
      key = "library/state.tfstate"
      region = "eu-west-3"
    }
}