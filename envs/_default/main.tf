module "supabase" {
  source = "../../terraform"
  do_token = data.aws_ssm_parameter.do_token.value
  aws_region = "eu-central-1"
  do_region = "fra1"
  domain = "makelocal.eu"
  site_url = "https://makelocal.eu"
  timezone = "Europe/Berlin"
  auth_user = "Make Local"
  smtp_city = "Berlin"
  smtp_country = "Germany"
  smtp_addr = "Makelocal"
  smtp_addr_2 = "Makelocal"
  smtp_state = "Berlin"
  smtp_zip_code = "10115"
  smtp_nickname = "Makelocal"
  smtp_reply_to = "info@makelocal.eu"
  smtp_reply_to_name = "Make Local"
  smtp_sender_name = "Make Local"
  smtp_host = "email-smtp.eu-central-1.amazonaws.com"
  smtp_port = 587
  smtp_user = aws_iam_access_key.ses_smtp_user.id
  smtp_password = aws_iam_access_key.ses_smtp_user.ses_smtp_password_v4
  smtp_admin_user = "info@makelocal.eu"
  storage_bucket_name = aws_s3_bucket.this.bucket
  spaces_access_key_id     = aws_iam_access_key.spaces_user.id
  spaces_secret_access_key = aws_iam_access_key.spaces_user.secret
}

resource "aws_iam_user" "ses_smtp_user" {
  name = "ses-smtp-user"
}

resource "aws_iam_access_key" "ses_smtp_user" {
  user = aws_iam_user.ses_smtp_user.name
}

resource "aws_iam_user_policy" "ses_smtp_user" {
  name = "ses-smtp-policy"
  user = aws_iam_user.ses_smtp_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendRawEmail",
          "ses:SendEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "random_id" "bucket" {
  byte_length = 8
  prefix      = "supabase-"
}
resource "aws_s3_bucket" "this" {
  bucket = random_id.bucket.hex
}
resource "aws_iam_user" "spaces_user" {
  name = "supabase-spaces-user"
}

resource "aws_iam_access_key" "spaces_user" {
  user = aws_iam_user.spaces_user.name
}

resource "aws_iam_user_policy" "spaces_user" {
  name = "spaces-policy"
  user = aws_iam_user.spaces_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.this.arn}",
          "${aws_s3_bucket.this.arn}/*"
        ]
      }
    ]
  })
}

output "supabase" {
  value = module.supabase
  sensitive = true
}

output "supabase_htpasswd" {
  value = module.supabase.htpasswd
}


