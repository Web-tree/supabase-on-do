module "main" {
  source = "../_default"
  env = "prod"
  
}
terraform {
  backend "s3" {
    bucket = "tf-state-bucket-084375558068"
    key    = "makelocal/supabase/terraform.tfstate"
    region = "eu-central-1"
  }
}

output "supabase" {
  value = module.main.supabase
  sensitive = true
}

output "supabase_htpasswd" {
  value = module.main.supabase_htpasswd
  sensitive = true
}
