#!/bin/bash

kubectl apply -f ./immutable-secret.yaml

kubectl apply -f ./patched-immutable-secret.yaml

kubectl delete -f ./immutable-secret.yaml