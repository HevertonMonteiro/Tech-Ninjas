provider "aws" {
  region = var.aws_region
}

# Criar Buckets S3
resource "aws_s3_bucket" "local_files" {
  bucket = "${var.bucket_prefix}-local-files"
}

resource "aws_s3_bucket" "bronze" {
  bucket = "${var.bucket_prefix}-bronze"
}

resource "aws_s3_bucket" "silver" {
  bucket = "${var.bucket_prefix}-silver"
}

resource "aws_s3_bucket" "gold" {
  bucket = "${var.bucket_prefix}-gold"
}

# Criar Tópico SNS
resource "aws_sns_topic" "file_notifications" {
  name = "${var.bucket_prefix}-file-notification-topic"
}

# Criar Fila SQS
resource "aws_sqs_queue" "file_queue" {
  name = "${var.bucket_prefix}-file-notification-queue"
}

# Subscrever a Fila SQS ao Tópico SNS
resource "aws_sns_topic_subscription" "sqs_subscription" {
  topic_arn = aws_sns_topic.file_notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.file_queue.arn
}

# Política para permitir que o SNS envie mensagens para a fila SQS
resource "aws_sqs_queue_policy" "file_queue_policy" {
  queue_url = aws_sqs_queue.file_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "sqs:SendMessage"
        Resource = aws_sqs_queue.file_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn": aws_sns_topic.file_notifications.arn
          }
        }
      }
    ]
  })
}

# Permissões para que o S3 publique no SNS
resource "aws_sns_topic_policy" "file_notifications_policy" {
  arn = aws_sns_topic.file_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "sns:Publish"
        Resource = aws_sns_topic.file_notifications.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn": "arn:aws:s3:::${var.bucket_prefix}-*"
          }
        }
      }
    ]
  })
}

# Configuração de Notificações para os Buckets S3
resource "aws_s3_bucket_notification" "bronze_notification" {
  bucket = aws_s3_bucket.bronze.bucket

  topic {
    topic_arn = aws_sns_topic.file_notifications.arn
    events    = ["s3:ObjectCreated:*"]
  }
}

resource "aws_s3_bucket_notification" "silver_notification" {
  bucket = aws_s3_bucket.silver.bucket

  topic {
    topic_arn = aws_sns_topic.file_notifications.arn
    events    = ["s3:ObjectCreated:*"]
  }
}

resource "aws_s3_bucket_notification" "gold_notification" {
  bucket = aws_s3_bucket.gold.bucket

  topic {
    topic_arn = aws_sns_topic.file_notifications.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
