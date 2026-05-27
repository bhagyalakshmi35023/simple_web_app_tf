terraform{
    backend  "s3"{
        bucket = "si-prod-s3"
        key    = "terraform.tfstate"
        region = "us-east-1"
        use_lockfile   = true        # for state locking
        encrypt        = true
  }
}