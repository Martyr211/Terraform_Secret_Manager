resource "random_password" "password" {
    length           = 16
    special          = true
    override_special = "_%@"
}

resource "aws_secretsmanager_secret" "secretmasterDB" {
    name = "Secret_DB_4"
}

resource "aws_secretsmanager_secret_rotation" "Secret_DB_Rotation" {
    secret_id = aws_secretsmanager_secret.secretmasterDB.id
    rotation_lambda_arn = aws_lambda_function.test_lambda.arn
    rotation_rules {
        automatically_after_days = 7
    }
}

resource "aws_secretsmanager_secret_version" "sversion" {
    secret_id     = aws_secretsmanager_secret.secretmasterDB.id
    secret_string = <<EOF
        {
            "username": "adminaccount_1",
            "password": "${random_password.password.result}",
            "database": "masterdb"
        }
    EOF
}




