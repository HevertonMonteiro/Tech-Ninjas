variable "aws_region" {
  description = "A região AWS onde os recursos serão criados"
  type        = string
  default     = "eu-central-1"
}

variable "bucket_prefix" {
  description = "Prefixo para os nomes dos buckets S3"
  type        = string
  default     = "teste4-bucket"
}
