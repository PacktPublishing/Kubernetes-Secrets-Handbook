#!/bin/bash


kubectl apply -f invalid_tls.yaml

kubectl delete -f ./invalid_tls.yaml

kubectl apply -f ./invalid_basic_auth.yaml  

kubectl delete -f ./invalid_basic_auth.yaml  

kubectl apply -f invalid_dockercfg.yaml 

