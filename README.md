# census-rm-data-exporter
The Data Exporter is a scheduled batch job that runs once a day and exports a full set of case, event and qid information from the case database. 
The data is exported in JSON format, zipped up and stored in a GCS bucket where it will be collected and sent downstream by MiNiFi.

## Running locally
The container is intended to be run within Kubernetes as a cronjob (see census-rm-kubernetes/optional folder)

### connect to an RM test kubernetes cluster
To test changes locally *connect to an existing RM test cluster* configured to support the dataexporter.

e.g.
gcloud beta container clusters get-credentials rm-k8s-cluster --region europe-west2 --project <SOME TEST PROJECT>

### obtain service account credentials for the dataexport service account
Create service account credentials for the dataexport service account and store in...
*~/.config/gcloud/service-account-key.json*


### store database connection certificates
Create new connection certificates and store in your *~/.postgresql/* directory
Ensure you are whitelisted against the test environment database.

### Run the test script
Use *./runlocaltest.sh*

This will set the docker-compose environment variables based on the configmaps and secrets contained within the rm cluster you are connected to. *you must be whitelisted against the database for this to work*




