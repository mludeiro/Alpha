minikube delete
minikube start

dapr init -k

echo Waiting for Dapr to start up ...
sleep 60
dapr status -k

kubectl create secret generic regcred --from-file=.dockerconfigjson=/home/mludeiro/.docker/config.json --type=kubernetes.io/dockerconfigjson

kubectl create secret generic alpha-secrets \
    --from-literal=token-db-connection='User ID=postgres;Password=password;Host=postgres-token;Port=5432;Database=token;' \
    --from-literal=identity-db-connection='User ID=postgres;Password=password;Host=postgres-identity;Port=5432;Database=identity;'

kubectl apply -f ./kubernetes/alpha-secretstore-kubernetes.yaml

# We need this for the "list" permission on secrets. Dapr has this role bind already
kubectl apply -f ./kubernetes/alpha-secret-read-role.yaml

# postgres implementation
kubectl apply -f ./kubernetes/postgres/postgres-configmap.yaml
kubectl apply -f ./kubernetes/postgres/psql-pv.yaml
kubectl apply -f ./kubernetes/postgres/psql-claim.yaml
kubectl apply -f ./kubernetes/postgres/ps-deployment.yaml
kubectl apply -f ./kubernetes/postgres/ps-service.yaml


# services implementation
kubectl apply -f ./kubernetes/services/token-service.yaml
kubectl wait deployments/token --for condition=Available

kubectl apply -f ./kubernetes/services/gateway-service.yaml
kubectl wait deployments/gateway --for condition=Available

kubectl apply -f ./kubernetes/services/frontend-service.yaml
kubectl wait deployments/frontend --for condition=Available

kubectl apply -f ./kubernetes/services/weather-service.yaml
kubectl wait deployments/weather --for condition=Available

kubectl apply -f ./kubernetes/services/identity-service.yaml
kubectl wait deployments/identity --for condition=Available

# helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
# helm repo update
# helm install ingress-nginx ingress-nginx/ingress-nginx --namespace default

minikube addons enable ingress

kubectl get ingress -A

sleep 20

kubectl apply -f ./ingress/gateway-ingress.yaml


minikube addons enable metrics-server
minikube dashboard

