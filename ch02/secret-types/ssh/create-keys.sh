#!/bin/bash

ssh-keygen -t rsa -f ./generated.key -C test -b 2048 -N "" 

kubectl create secret generic ssh-secret --from-file=id_rsa=./generated.key --from-file=id_rsa.pub=./generated.key.pub 

kubectl apply -f ./pod-with-ssh-keys.yaml

kubectl wait --for=condition=ready pod/pod-with-ssh-keys

kubectl logs pod-with-ssh-keys

kubectl delete -f ./pod-with-ssh-keys.yaml

rm ./generated.key ./generated.key.pub