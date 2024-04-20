minikube delete
minikube start --memory=8192 --cpus=4

dapr init -k --wait

dapr status -k



# create namespaces
kubectl create namespace alpha-prod

kubectl config set-context --current --namespace=alpha-prod

kubectl create secret generic regcred --from-file=.dockerconfigjson=/home/mludeiro/.docker/config.json --type=kubernetes.io/dockerconfigjson

kubectl create secret generic alpha-secrets \
    --from-literal=token-db-connection='User ID=postgres;Password=password;Host=postgres-token;Port=5432;Database=token;' \
    --from-literal=identity-db-connection='User ID=postgres;Password=password;Host=postgres-identity;Port=5432;Database=identity;'

kubectl apply -f ./kubernetes/alpha-secretstore-kubernetes.yaml

# We need this for the "list" permission on secrets. Dapr has this role bind already.
kubectl apply -f ./kubernetes/alpha-secret-read-role.yaml
# Use that role in alpha-prod namespace
# (defined in yaml) kubectl create rolebinding allow-secret-reader --serviceaccount=alpha-prod:default --namespace=alpha-prod --role=secret-reader

#redis
kubectl apply -f ./kubernetes/redis.yaml
kubectl wait deployments/redis --for condition=Available --namespace=tools
kubectl apply -f ./kubernetes/alpha-distributedlock.yaml


# postgres implementation
kubectl apply -f ./kubernetes/postgres/postgres-configmap.yaml
kubectl apply -f ./kubernetes/postgres/psql-pv.yaml
kubectl apply -f ./kubernetes/postgres/psql-claim.yaml
kubectl apply -f ./kubernetes/postgres/ps-deployment.yaml
kubectl apply -f ./kubernetes/postgres/ps-service.yaml

# services implementation
kubectl apply -f ./kubernetes/services/token-service.yaml
kubectl wait deployments/token --for condition=Available --timeout=90s --namespace=alpha-prod

kubectl apply -f ./kubernetes/services/gateway-service.yaml
kubectl wait deployments/gateway --for condition=Available --timeout=90s --namespace=alpha-prod

kubectl apply -f ./kubernetes/services/frontend-service.yaml
kubectl wait deployments/frontend --for condition=Available --timeout=90s --namespace=alpha-prod

kubectl apply -f ./kubernetes/services/weather-service.yaml
kubectl wait deployments/weather --for condition=Available --timeout=90s --namespace=alpha-prod

kubectl apply -f ./kubernetes/services/identity-service.yaml
kubectl wait deployments/identity --for condition=Available --timeout=90s --namespace=alpha-prod

# helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
# helm repo update
# helm install ingress-nginx ingress-nginx/ingress-nginx 

minikube addons enable ingress

kubectl get ingress -A

sleep 20

kubectl apply -f ./kubernetes/frontend-ingress.yaml


minikube addons enable metrics-server
minikube dashboard

