#!/bin/bash -e
echo "--------------------------------------------------------------------------------"
echo `date +%Y-%m-%d_%H-%M-%S`" - Bootstrapping the etcd Cluster"
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp controller-01.sh ${instance}:~/
  gcloud compute ssh ${instance} --command="/bin/bash controller-01.sh"
done

echo
echo `date +%Y-%m-%d_%H-%M-%S`" - Verification"
gcloud compute ssh controller-2 --command="ETCDCTL_API=3 etcdctl member list" >> log.txt
