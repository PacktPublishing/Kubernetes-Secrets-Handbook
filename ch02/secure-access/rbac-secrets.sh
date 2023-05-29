#!/bin/bash

kubectl api-resources -o wide|grep secrets

kubectl create secret generic opaque-example-from-literals --from-literal=literal1=text-for-literal-1

kubectl create sa secret-viewer

kubectl create sa secret-admin

kubectl apply -f secret-admin.yaml

kubectl apply -f secret-viewer.yaml

kubectl run -i --tty kubectl --overrides='{ "spec": { "serviceAccount": "secret-viewer" }  }' -n default --image=bitnami/kubectl:latest get secret opaque-example-from-literals