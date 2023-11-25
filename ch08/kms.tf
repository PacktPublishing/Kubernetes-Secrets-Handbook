resource "aws_kms_key" "ksm_kms_key" {
  description             = "ksm_kms_key"
  deletion_window_in_days = 30  
  enable_key_rotation     = true
}