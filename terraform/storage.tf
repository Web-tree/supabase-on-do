resource "aws_s3_bucket_policy" "this" {
  bucket = var.storage_bucket_name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "IPAllow",
        "Effect" : "Deny",
        "Principal" : "*",
        "Action" : "s3:*",
        "Resource" : [
          "arn:aws:s3:::${var.storage_bucket_name}",
          "arn:aws:s3:::${var.storage_bucket_name}/*"
        ],
        "Condition" : {
          "NotIpAddress" : {
            "aws:SourceIp" : "${local.spaces_ip_range}"
          }
        }
      }
    ]
  })
}

resource "digitalocean_volume" "this" {
  region                  = var.do_region
  name                    = "supabase-volume"
  size                    = var.volume_size
  initial_filesystem_type = "ext4"
  description             = "Supabase PostgreSQL Persistant Volume."
}

