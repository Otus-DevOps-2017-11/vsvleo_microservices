#!/bin/bash -e
echo "--------------------------------------------------------------------------------"
echo "Bootstrapping the Kubernetes Worker Nodes"
for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp worker-01.sh ${instance}:~/
  gcloud compute ssh ${instance} --command="/bin/bash worker-01.sh"
done

echo
echo `date +%Y-%m-%d_%H-%M-%S`" - Verification"
gcloud compute ssh controller-0 --command="kubectl get nodes"
