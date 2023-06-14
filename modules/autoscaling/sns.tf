resource "aws_sns_topic" "cpu_usage_topic" {
  name = "cpu-usage-topic"
}

# policy to allow cloudwatch service to publish to SNS
data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.cpu_usage_topic.arn,
    ]
    sid = "__default_statement_ID"
  }
}

# attach above policy to specific cpu sns topic
resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.cpu_usage_topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

resource "aws_sns_topic_subscription" "cpu_usage_subscription" {
  topic_arn = aws_sns_topic.cpu_usage_topic.arn
  protocol  = "email"
  endpoint  = "valentin_kalbov@flutterint.com"
}