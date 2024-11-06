resource "aws_cloudwatch_event_rule" "sg_authorization_rule" {
  name        = "sg-authorization-rule"
  description = "Sg auhtorization rule lab"
  event_pattern = jsonencode({
    "source": ["aws.ec2"],
    "detail-type": ["AWS API Call via CloudTrail"],
    "detail": {
      "eventSource": ["ec2.amazonaws.com"],
      "eventName": ["AuthorizeSecurityGroupIngress"]
    }
  })
}

resource "aws_lambda_permission" "eventbridge_lambda" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sg_authorization_rule.arn
}

resource "aws_cloudwatch_event_target" "sg_auhtorization_target" {
  rule      = aws_cloudwatch_event_rule.sg_authorization_rule.name
  arn       = aws_lambda_function.lambda.arn  
}