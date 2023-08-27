resource "aws_secretsmanager_secret" "ksm_service_token" {
  name        = "service_token"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "ksm_service_token_first_version" {
  secret_id     = aws_secretsmanager_secret.ksm_service_token.id
  secret_string = "a-service-token"
}

resource "aws_iam_policy" "ksm_service_token_reader" {
    name = "get-service-token"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
            "Effect": "Allow",
            "Action": ["secretsmanager:GetSecretValue","secretsmanager:DescribeSecret"],
            "Resource": aws_secretsmanager_secret_version.ksm_service_token_first_version.arn
        }
      ]
    })
  
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "eks_secret_reader_role" {
  name = "eks-secret-reader"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.ksm_eks.oidc_provider}"
        }
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${module.ksm_eks.oidc_provider}:aud": "sts.amazonaws.com",
            "${module.ksm_eks.oidc_provider}:sub": "system:serviceaccount:default:service-token-reader"
        }
      }
      }
    ]
  })


}

resource "aws_iam_role_policy_attachment" "esrrs" {
  policy_arn = aws_iam_policy.ksm_service_token_reader.arn
  role       = aws_iam_role.eks_secret_reader_role.name
}