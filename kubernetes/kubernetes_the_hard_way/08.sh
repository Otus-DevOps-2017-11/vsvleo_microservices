#!/bin/bash -e
echo "--------------------------------------------------------------------------------"
echo "Bootstrapping the Kubernetes Control Plane"
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp controller-02.sh ${instance}:~/
  gcloud compute ssh ${instance} --command="/bin/bash controller-02.sh"
done
echo "RBAC for Kubelet Authorization"
gcloud compute scp controller-03.sh controller-0:~/
gcloud compute ssh controller-0 --command="/bin/bash controller-03.sh"

echo
echo `date +%Y-%m-%d_%H-%M-%S`" - The Kubernetes Frontend Load Balancer"
gcloud compute target-pools create kubernetes-target-pool
gcloud compute target-pools add-instances kubernetes-target-pool \
  --instances controller-0,controller-1,controller-2
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(name)')
gcloud compute forwarding-rules create kubernetes-forwarding-rule \
  --address ${KUBERNETES_PUBLIC_ADDRESS} \
  --ports 6443 \
  --region $(gcloud config get-value compute/region) \
  --target-pool kubernetes-target-pool

echo
echo `date +%Y-%m-%d_%H-%M-%S`" - Verification"
KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')
curl --cacert ca.pem https://${KUBERNETES_PUBLIC_ADDRESS}:6443/version
