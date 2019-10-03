#!/bin/bash

helpFunction()
{
    echo "Empty or wrong parameters"
    echo ".env.dev and .env.prod should be present"
    echo "Usage: $0 dev|prod"
    exit 1 # Exit script after printing help
}


checkFile() {
    if test ! -f "$1"; then
        helpFunction
    fi
}


if [ -z "$1" ]; then
    helpFunction
fi



PROPS_DEV=.env.dev
PROPS_PROD=.env.prod

checkFile "$PROPS_DEV"
checkFile "$PROPS_PROD"


if [ "$1" = "dev" ]; then
    echo "Create dev values"
    PROPS=.env.dev
    SS_DIR=overlays/development
    NS=development
    elif [ "$1" = "prod" ]; then
    echo "Create production values"
    PROPS=.env.prod
    SS_DIR=overlays/production
    NS=production
else
    helpFunction
fi;

SOME_TEMP=$(mktemp -d)
mkdir -p $SOME_TEMP

kubectl create secret generic dt65-secret -n $NS --from-env-file=$PROPS --dry-run -o yaml > $SOME_TEMP/secret.yaml
kubeseal --format yaml --cert ss-cert.pem <$SOME_TEMP/secret.yaml >$SS_DIR/sealed-secrets.yaml

kubectl create secret generic gce-secret -n $NS --from-file=service_account_key=gce-storage-service-account.json --dry-run -o yaml > $SOME_TEMP/gce-secret.yaml
kubeseal --format yaml --cert ss-cert.pem <$SOME_TEMP/gce-secret.yaml >$SS_DIR/sealed-secrets-gce.yaml

rm -r $SOME_TEMP
echo "SealedSecret created"