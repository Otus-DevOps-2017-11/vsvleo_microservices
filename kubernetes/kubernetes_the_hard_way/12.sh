#!/bin/bash
echo "--------------------------------------------------------------------------------"
echo "Deploying the DNS Cluster Add-on"
echo `date +%Y-%m-%d_%H-%M-%S`" - The DNS Cluster Add-on"
kubectl create -f https://storage.googleapis.com/kubernetes-the-hard-way/kube-dns.yaml
kubectl get pods -l k8s-app=kube-dns -n kube-system

echo
echo `date +%Y-%m-%d_%H-%M-%S`" - Verification"
kubectl run busybox --image=busybox --command -- sleep 3600
kubectl get pods -l run=busybox
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
kubectl exec -ti $POD_NAME -- nslookup kubernetes
