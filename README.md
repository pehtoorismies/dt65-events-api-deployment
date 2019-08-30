# Prerequisites

## Create namespaces

Because *kustomize.io* and *Sealed Secrets* don't play well together (plugin needed) different namespaces will be used.

```
# development & production
kubectl apply -f config/namespaces.yaml
```

## Install mongo

```
# development
helm install mongo stable/mongodb \
    -n development \
    -f config/mongo-dev.yaml \
    --set mongodbRootPassword=<secret>,mongodbUsername=<secret>,mongodbPassword=<secret>

# production
helm install mongo stable/mongodb \
    -n production \
    -f config/mongo-prod.yaml \
    --set mongodbRootPassword=<secret>,mongodbUsername=<secret>,mongodbPassword=<secret>
```

Mongo client
```
export MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace development mongo-mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)
kubectl run --namespace development mongo-mongodb-client --rm --tty -i --restart='Never' --image bitnami/mongodb --command -- mongo admin --host mongo-mongodb --authenticationDatabase admin -u root -p $MONGODB_ROOT_PASSWORD
```

## Install Sealed Secrets

Store public key

```
kubeseal --fetch-cert > ss-cert.pem
```

Create secret

```
./createSealed.sh dev
```

## Install Kustomize


Test creation
```
kustomize build > temp.yaml
```

## Install Flux

```
kustomize build config/fluxcd
```

## Install Nginx Ingress Controller

Follow instructions: https://kubernetes.github.io/ingress-nginx/deploy/

## Install Cert-manager
