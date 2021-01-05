# census-rm-data-exporter
The Data Exporter is a scheduled batch job that runs once a day via a crontab job, or for a given start & end datetime. The data exporter exports a full set of case, event and qid information from the case database. 
The data is exported in JSON format, zipped up and stored in a GCS bucket where it will be collected and sent downstream by MiNiFi.

## Running locally
The container is intended to be run within Kubernetes either as a cronjob (which will be run for the previous day as default), or with a start/end datetime.
To run with a start/end datetime, connect to the one-off dataexport pod with bash, then run the job as follows:
```
START_DATETIME=<YYYY-MM-DDTHH:MM:SS> END_DATETIME=<YYYY-MM-DDTHH:MM:SS> ./run.sh
```

For example:
```
START_DATETIME=2020-12-01T00:00:00 END_DATETIME=2020-12-03T23:59:59.999999 ./run.sh
```

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



