minikube delete
minikube start

dapr init -k

echo Waiting for Dapr to start up ...
sleep 60
dapr status -k

kubectl create secret generic regcred --from-file=.dockerconfigjson=/home/mludeiro/.docker/config.json --type=kubernetes.io/dockerconfigjson

kubectl create secret generic alpha-secrets \
    --from-literal=token-db-connection='User ID=postgres;Password=password;Host=postgres;Port=5432;Database=token;' \
    --from-literal=identity-db-connection='User ID=postgres;Password=password;Host=postgres;Port=5432;Database=identity;'

token-db-connection = User ID=postgres;Password=password;Host=postgres;Port=5432;Database=token;
identity-db-connection = User ID=postgres;Password=password;Host=postgres;Port=5432;Database=identity;

kubectl create secret generic alpha-secrets --from-file=./dapr/configuration/secrets.txt

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
sleep 10
kubectl apply -f ./kubernetes/services/identity-service.yaml
sleep 10
kubectl apply -f ./kubernetes/services/gateway-service.yaml
sleep 10
kubectl apply -f ./kubernetes/services/frontend-service.yaml
sleep 10
kubectl apply -f ./kubernetes/services/weather-service.yaml
sleep 10

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace default


minikube addons enable metrics-server
minikube dashboard
