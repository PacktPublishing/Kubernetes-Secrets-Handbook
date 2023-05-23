#!/bin/bash

openssl genrsa -des3 -passout pass:test -out ca.key 4096
#Remove passphrase for example purposes
openssl rsa -passin pass:test -in ca.key -out ca.key
openssl req -new -x509 -days 3650 -key ca.key -subj "/CN=webpage.your.hostname" -out ca.crt

openssl genrsa -des3 -passout pass:test -out server.key 2048
openssl rsa -passin pass:test -in server.key -out server.key

openssl req -new -key server.key -subj "/CN=webpage.your.hostname" -out server.csr

openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt

CRT=$(cat server.crt|base64)
KEY=$(cat server.key|base64)

cat tls-secret-template.yaml|sed "s/CRT/$CRT/" |sed "s/KEY/$KEY/" > tls-secret.yaml

kubectl apply -f ./tls-secret.yaml