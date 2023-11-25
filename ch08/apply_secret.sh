#!/bin/bash

region="eu-west-1"

account_id=$(aws sts get-caller-identity --query "Account" --output text)

secret_arn=$(aws secretsmanager list-secrets --region $region --filter Key="name",Values="service-token" --query 'SecretList[0].ARN')

secret_provider_template=$(cat secret-provider-class.template.yaml)

printf $secret_provider_template $secret_arn > secret-provider-class.yaml

kubectl apply -f secret-provider-class.yaml

rm secret-provider-class.yaml

service_account_template=$(cat service-account.template.yaml)

printf $service_account_template  $account_id > service-account.yaml

kubectl apply -f service-account.yaml

rm service-account.yaml

kubectl apply -f pod.yaml