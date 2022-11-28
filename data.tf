# data "aws_secretsmanager_secret" "secretmasterDB" {
#     arn = aws_secretsmanager_secret.secretmasterDB.arn
# }

# data "aws_secretsmanager_secret_version" "creds" {
#     secret_id = data.aws_secretsmanager_secret.secretmasterDB.arn
# }

# locals {
#     db_creds = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
# }

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}