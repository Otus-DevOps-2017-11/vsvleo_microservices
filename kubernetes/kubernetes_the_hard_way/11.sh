#!/bin/bash
echo "--------------------------------------------------------------------------------"
echo "Provisioning Pod Network Routes"
echo `date +%Y-%m-%d_%H-%M-%S`" - The Routing Table"
for instance in worker-0 worker-1 worker-2; do
  gcloud compute instances describe ${instance} \
    --format 'value[separator=" "](networkInterfaces[0].networkIP,metadata.items[0].value)'
done

echo
echo `date +%Y-%m-%d_%H-%M-%S`" - Routes"
for i in 0 1 2; do
  gcloud compute routes create kubernetes-route-10-200-${i}-0-24 \
    --network kubernetes-the-hard-way \
    --next-hop-address 10.240.0.2${i} \
    --destination-range 10.200.${i}.0/24
done
gcloud compute routes list --filter "network: kubernetes-the-hard-way"
