#!/bin/bash

kubectl port-forward svc/argocd-server -n argocd 8080:443 &

sleep 5

argocd admin initial-password -n argocd


read -p 'Password: ' password

argocd login 127.0.0.1:8080 --username admin --password $password --insecure

argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace default

argocd app sync guestbook