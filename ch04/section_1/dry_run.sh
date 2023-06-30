#!/bin/bash

kubectl create secret generic opaque-example-from-literals --from-litaeral=literal1=text-for-literal-1 --dry-run=client

kubectl create secret generic opaque-example-from-literals --from-literal=literal1=text-for-literal-1 --dry-run=client -o yaml