#!/bin/bash

kubectl create secret generic opaque-example-from-literals --from-literal=literal1=text-for-literal-1

kubectl get secret opaque-example-from-literals -o yaml

kubectl delete secret opaque-example-from-literals

kubectl create secret generic secretfile --from-file=secret-file.txt=./secret.file.txt

kubectl get secret secretfile -o yaml

kubectl delete secret secretfile
