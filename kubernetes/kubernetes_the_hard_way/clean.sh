#!/bin/bash
echo "Cleaning Up"

echo
echo `date +%Y-%m-%d_%H-%M-%S`" - Compute Instances"
gcloud -q compute instances delete \
  controller-0 controller-1 controller-2 \
  worker-0 worker-1 worker-2

echo
echo `date +%Y-%m-%d_%H-%M-%S`" - Networking"

echo "Delete the external load balancer network resources:"

gcloud -q compute forwarding-rules delete kubernetes-forwarding-rule \
  --region $(gcloud config get-value compute/region)

gcloud -q compute target-pools delete kubernetes-target-pool

echo "Delete the kubernetes-the-hard-way static IP address:"

gcloud -q compute addresses delete kubernetes-the-hard-way

echo "Delete the kubernetes-the-hard-way firewall rules:"

gcloud -q compute firewall-rules delete \
  kubernetes-the-hard-way-allow-nginx-service \
  kubernetes-the-hard-way-allow-internal \
  kubernetes-the-hard-way-allow-external

echo "Delete the Pod network routes:"

gcloud -q compute routes delete \
  kubernetes-route-10-200-0-0-24 \
  kubernetes-route-10-200-1-0-24 \
  kubernetes-route-10-200-2-0-24

echo "Delete the kubernetes subnet:"

gcloud -q compute networks subnets delete kubernetes

echo "Delete the kubernetes-the-hard-way network VPC:"

gcloud -q compute networks delete kubernetes-the-hard-way
