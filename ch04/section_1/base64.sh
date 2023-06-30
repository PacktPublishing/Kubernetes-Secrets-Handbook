#!/bin/bash

secretKey=$(openssl rand -hex 32)
echo "$secretKey"

kubectl create secret generic aes-key --from-literal=key=$secretKey -o yaml

kubectl apply -f ./base_64_example.yaml

kubectl wait --for=condition=ready pod/print-env-pod 

kubectl logs print-env-pod|grep key

kubectl delete -f ./base_64_example.yaml

kubectl delete secret aes-key

cat base_64_example_key.yaml|sed "s/KEY_PLACEHOLDER/$secretKey/" > temporary_base_64_example_key.yaml

cat temporary_base_64_example_key.yaml

kubectl apply -f ./temporary_base_64_example_key.yaml

kubectl apply -f ./base_64_example.yaml

kubectl wait --for=condition=ready pod/print-env-pod 

kubectl logs print-env-pod|grep key

kubectl delete -f ./base_64_example.yaml

kubectl delete secret aes-key
