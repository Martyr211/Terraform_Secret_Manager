resource "aws_iam_role" "role_for_lambda" {
  name = "Secret_Rotation_Lambda_Role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole"
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "policy_for_lambda_1" {
  name = "Secret_Rotation_Lambda_Policy"
  policy = templatefile("${path.module}/policy/lambda_policy.json",
    {
      account_num          = data.aws_caller_identity.current.account_id
      aws_region           = data.aws_region.current.name
      lambda_func          = aws_lambda_function.test_lambda.function_name
    }
  )
}

resource "aws_iam_policy" "policy_for_lambda_2" {
  name = "Lambda_SM_Inline_Policy"
  policy = templatefile("${path.module}/policy/lambda_inline_policy.json",
    {
      account_num          = data.aws_caller_identity.current.account_id
      aws_region           = data.aws_region.current.name
      secret_arn          = aws_secretsmanager_secret.secretmasterDB.arn
    }
  )
}

resource "aws_iam_role_policy_attachment" "policy_attachment_for_lambda_1" {
  depends_on = [
    aws_iam_role.role_for_lambda,
    aws_iam_policy.policy_for_lambda_1
  ]
  role       = aws_iam_role.role_for_lambda.id
  policy_arn = aws_iam_policy.policy_for_lambda_1.arn
}

resource "aws_iam_role_policy_attachment" "policy_attachment_for_lambda_2" {
  depends_on = [
    aws_iam_role.role_for_lambda,
    aws_iam_policy.policy_for_lambda_2
  ]
  role       = aws_iam_role.role_for_lambda.id
  policy_arn = aws_iam_policy.policy_for_lambda_2.arn
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/lambda_python.zip"
}

resource "aws_lambda_function" "test_lambda" {
  architectures    = ["x86_64"]
  filename         = "${path.module}/lambda_python.zip"
  function_name    = "Secret_Rotation_Function"
  role             = aws_iam_role.role_for_lambda.arn
  handler          = "lambda.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda_python.zip")
  runtime          = "python3.9"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "SecretManagerRotation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "secretsmanager.amazonaws.com"
}

    