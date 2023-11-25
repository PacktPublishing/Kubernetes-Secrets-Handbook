#!/bin/bash

cluster_name=eks-ksm-cluster
region="eu-west-1"

account_id=$(aws sts get-caller-identity --query "Account" --output text)

aws eks --region $region update-kubeconfig --name $cluster_name

helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install -n kube-system csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver
helm repo add aws-secrets-manager https://aws.github.io/secrets-store-csi-driver-provider-aws
helm install -n kube-system secrets-provider-aws aws-secrets-manager/secrets-store-csi-driver-provider-aws