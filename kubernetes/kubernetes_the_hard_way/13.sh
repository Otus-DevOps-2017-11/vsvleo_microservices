#!/bin/bash
echo "--------------------------------------------------------------------------------"
echo "Smoke Test"
echo `date +%Y-%m-%d_%H-%M-%S`" - Data Encryption"
#kubectl create secret generic kubernetes-the-hard-way \
#  --from-literal="mykey=mydata"
#gcloud compute ssh controller-0 \
#  --command "ETCDCTL_API=3 etcdctl get /registry/secrets/default/kubernetes-the-hard-way | hexdump -C"

echo
echo `date +%Y-%m-%d_%H-%M-%S`" - Deployments"
#kubectl run nginx --image=nginx
#kubectl get pods -l run=nginx

echo
echo `date +%Y-%m-%d_%H-%M-%S`" - Port Forwarding"
POD_NAME=$(kubectl get pods -l run=nginx -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:80 &
PID=`jobs -p`
sleep 2
curl --head http://127.0.0.1:8080
kill $PID

echo
echo `date +%Y-%m-%d_%H-%M-%S`" - Logs"
kubectl logs $POD_NAME

echo
echo `date +%Y-%m-%d_%H-%M-%S`" - Exec"
kubectl exec -ti $POD_NAME -- nginx -v

echo
echo `date +%Y-%m-%d_%H-%M-%S`" - Services"
kubectl expose deployment nginx --port 80 --type NodePort
NODE_PORT=$(kubectl get svc nginx \
  --output=jsonpath='{range .spec.ports[0]}{.nodePort}')
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-nginx-service \
  --allow=tcp:${NODE_PORT} \
  --network kubernetes-the-hard-way
EXTERNAL_IP=$(gcloud compute instances describe worker-0 \
  --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')
curl -I http://${EXTERNAL_IP}:${NODE_PORT}
