# set env variables required for docker-compose
export DATAEXPORT_DB_HOST=$(gcloud sql instances list --filter "name:rm-postgres*" --format="value(ipAddresses[0].ipAddress)")
export DATAEXPORT_DB_NAME=$(kubectl get configmap db-config -o jsonpath='{.data.db-name}')
export DATAEXPORT_DB_PORT=$(kubectl get configmap db-config -o jsonpath='{.data.db-port}')
export DATAEXPORT_BUCKET_NAME=$(kubectl get configmap dataexport-config -o jsonpath='{.data.bucket-name}')
export DATAEXPORT_DB_USERNAME=$(kubectl get secret db-credentials -o jsonpath='{.data.username}')
export DATAEXPORT_DB_PASSWORD=$(kubectl get secret db-credentials -o jsonpath='{.data.password}')

docker-compose up