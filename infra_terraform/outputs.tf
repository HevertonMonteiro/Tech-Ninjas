output "sns_topic_arn" {
  description = "O ARN do tópico SNS para notificações"
  value       = aws_sns_topic.file_notifications.arn
}

output "sqs_queue_arn" {
  description = "O ARN da fila SQS"
  value       = aws_sqs_queue.file_queue.arn
}

output "s3_buckets" {
  description = "Lista dos nomes dos buckets S3 criados"
  value       = [
    aws_s3_bucket.local_files.bucket,
    aws_s3_bucket.bronze.bucket,
    aws_s3_bucket.silver.bucket,
    aws_s3_bucket.gold.bucket
  ]
}
