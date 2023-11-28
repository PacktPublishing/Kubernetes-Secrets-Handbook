#!/bin/bash

kubectl apply -f secret.yaml
kubectl apply -f tekton-task.yaml 