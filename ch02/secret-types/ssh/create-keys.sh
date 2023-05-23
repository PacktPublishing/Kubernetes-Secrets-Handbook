#!/bin/bash

ssh-keygen -t rsa -f ./generated.key -C test -b 2048 -N "" 

kubectl create secret generic ssh-secret --from-file=id_rsa=./generated.key --from-file=id_rsa.pub=./generated.key.pub 

kubectl apply -f ssh-server.yaml

kubectl logs pod-with-ssh-keys