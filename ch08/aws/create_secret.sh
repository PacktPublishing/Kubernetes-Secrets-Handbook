#!/bin/bash

region="eu-west-1"

account_id=$(aws sts get-caller-identity --query "Account" --output text)

oidc_provider=$(aws eks describe-cluster --name eks-ksm-cluster --region $region --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")

aws secretsmanager create-secret --name service-token --region $region --secret-string a-service-token  --add-replica-regions Region=eu-central-1

template=$(cat eks-reader-trust-policy.template.json)

printf $template $account_id $oidc_provider $oidc_provider $oidc_provider > eks-reader-trust-policy.json

aws iam create-role --role-name eks-secret-reader --assume-role-policy-document file://eks-reader-trust-policy.json

rm eks-reader-trust-policy.json

policy_template=$(cat policy.template.json)

secret_arn=$(aws secretsmanager list-secrets --region $region --filter Key="name",Values="service-token" --query 'SecretList[0].ARN')

printf $policy_template $secret_arn > policy.json

aws iam create-policy --policy-name get-service-token --policy-document  file://policy.json

rm policy.json

aws iam attach-role-policy --role-name eks-secret-reader --policy-arn arn:aws:iam::$account_id:policy/get-service-token
