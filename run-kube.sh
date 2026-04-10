#!/bin/bash

# Manually apply the following in order, if desired. 
# The k8s/ directory contains all of these in the correct order, 
# so you can just apply that instead => kubectl apply -f k8s/
# kubectl apply -f 00-namespace.yaml
# kubectl apply -f postgres/
# kubectl apply -f redis/
# kubectl apply -f app/

kubectl apply -f k8s/
kubectl get all -n ufology