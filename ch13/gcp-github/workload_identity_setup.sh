#!/bin/bash

gcloud iam workload-identity-pools create "ga-ksm-pool" --project="${GCP_PROJECT_ID}"  --location="global" --display-name="GitHub actions Pool"

gcloud iam workload-identity-pools providers create-oidc "github" \
    --project="${GCP_PROJECT_ID}" \
    --location="global" \
    --workload-identity-pool="ga-ksm-pool" \
    --display-name="Github provider" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.aud=assertion.aud" \
    --issuer-uri="https://token.actions.githubusercontent.com"

gcloud iam service-accounts create github-service-account

project_number=$(gcloud projects list --filter="$(gcloud config get-value project)" --format="value(PROJECT_NUMBER)")

gcloud secrets add-iam-policy-binding ksm-secret --member="serviceAccount:github-service-account@${GCP_PROJECT_ID}.iam.gserviceaccount.com" --role=roles/secretmanager.viewer

gcloud iam service-accounts add-iam-policy-binding "github-service-account@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
    --project="${GCP_PROJECT_ID}" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/${project_number}/locations/global/workloadIdentityPools/ga-ksm-pool/attribute.repository/${github_organisation_or_username}/${github_repositoryname}"