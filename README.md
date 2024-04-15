# Bar Microservices

This project is an example of a clud microservices using docker, postgres, mongodb, kafka, DDD and CQRS


## Kubernates configuration

# Requirements
    -   Minikube    => https://kubernetes.io/docs/tasks/tools/
    -   Kubectl     => https://kubernetes.io/docs/tasks/tools/
    -   Dapr        => https://docs.dapr.io/getting-started/install-dapr-cli/

```
# start K8s local cluster
minikube start

# add secret for github docker repo acess
kubectl create secret generic regcred --from-file=.dockerconfigjson=/home/mludeiro/.docker/config.json --type=kubernetes.io/dockerconfigjson

# add secrets for db access
kubectl create secret generic alpha-secrets --from-file=./dapr/configuration/secrets.json

# init Dapr on K8s
dapr init -k

# Optional - check Dapr status
dapr status -k

# Optional - check Dapr dashboard
dapr dashboard -k [port]

```

