#!/bin/bash
echo "running rm-dataexporter job $(date)"

# exit on errors, including unset variables (nounset)
set -o errexit  
set -o pipefail
set -o nounset
# uncomment for trace
# set -o xtrace


############################################################################
# PREPARE POSTGRES CERTIFICATES
# convert java pk8 required key format to pem if we're running in kubernetes
############################################################################
if [[ -f /root/.postgresql/postgresql.pk8 ]]; then
  echo "creating client-key.pem file from postgresql.pk8"
  openssl pkcs8 -in /root/.postgresql/postgresql.pk8 -inform der -nocrypt -out /tmp/client-key.pem
  chmod 600 /tmp/client-key.pem
fi

# run all data exports in persistent volume mounted directory
cd $PVC_MOUNT_PATH

######################################################################
# EXPORT UAC_QID_LINK TABLE AND UPLOAD FILE AND MANIFEST TO GCS BUCKET
######################################################################
echo "exporting uac_qid_link table content (no UACs)"



QID_FILE=qid_$(date +"%Y-%m-%dT%H-%M-%S").json

PGPASSWORD=$DB_PASSWORD psql "sslmode=verify-ca sslrootcert=/root/.postgresql/root.crt sslcert=/root/.postgresql/postgresql.crt sslkey=/tmp/client-key.pem hostaddr=$DB_HOST port=$DB_PORT user=$DB_USERNAME dbname=rm" \
-c "\copy (SELECT row_to_json(t) FROM (SELECT id,qid,caze_case_ref as case_ref FROM casev2.uac_qid_link) t) To '$QID_FILE';"


echo "zipping uac_qid_link file"

filename=CensusResponseManagement_qid_$(date +"%Y-%m-%dT%H-%M-%S").zip
zip "$filename" "$QID_FILE"

echo "adding $filename to bucket $BUCKET_NAME"
gsutil -q cp "$filename" gs://"$BUCKET_NAME"

echo "write manifest $filename.manifest"

cat > "$filename".manifest <<-EOF
{
  "schemaVersion": 1,
  "files": [
    {
      "sizeBytes": $(stat -c%s $filename),
      "md5sum": "$(openssl md5 "$filename" | awk '{ print $2 }')",
      "relativePath": "./",
      "name": "$filename"
    }
  ],
  "sourceName": "RM",
  "manifestCreated": "$(date +'%Y-%m-%dT%H:%M:%S').0000000Z",
  "description": "RM uac_qid_link table export",
  "dataset": "RM_cases",
  "version": 1
}
EOF

echo "adding $filename.manifest to bucket $BUCKET_NAME"
gsutil -q cp "$filename".manifest gs://"$BUCKET_NAME"

# cleanup files
rm $filename
rm "$filename".manifest

######################################################################
# EXPORT CASES TABLE AND UPLOAD FILE AND MANIFEST TO GCS BUCKET
######################################################################
echo "exporting cases table content"


CASES_FILE=cases_$(date +"%Y-%m-%dT%H-%M-%S").json

PGPASSWORD=$DB_PASSWORD psql "sslmode=verify-ca sslrootcert=/root/.postgresql/root.crt sslcert=/root/.postgresql/postgresql.crt sslkey=/tmp/client-key.pem hostaddr=$DB_HOST port=$DB_PORT user=$DB_USERNAME dbname=rm" \
-c "\copy (SELECT row_to_json(t) FROM (SELECT * FROM casev2.cases) t) To '$CASES_FILE';"


echo "zipping cases file"

filename=CensusResponseManagement_case_$(date +"%Y-%m-%dT%H-%M-%S").zip
zip "$filename" "$CASES_FILE"

echo "adding $filename to bucket $BUCKET_NAME"
gsutil -q cp "$filename" gs://"$BUCKET_NAME"

echo "write manifest $filename.manifest"

cat > "$filename".manifest <<-EOF
{
  "schemaVersion": 1,
  "files": [
    {
      "sizeBytes": $(stat -c%s $filename),
      "md5sum": "$(openssl md5 "$filename" | awk '{ print $2 }')",
      "relativePath": "./",
      "name": "$filename"
    }
  ],
  "sourceName": "RM",
  "manifestCreated": "$(date +'%Y-%m-%dT%H:%M:%S').0000000Z",
  "description": "RM cases table export",
  "dataset": "RM_cases",
  "version": 1
}
EOF

echo "adding $filename.manifest to bucket $BUCKET_NAME"
gsutil -q cp "$filename".manifest gs://"$BUCKET_NAME"

# cleanup files
rm $filename
rm "$filename".manifest


######################################################################
# EXPORT EVENT TABLE AND UPLOAD FILE AND MANIFEST TO GCS BUCKET
######################################################################
echo "exporting event table content"


EVENTS_FILE=events_$(date +"%Y-%m-%dT%H-%M-%S").json

PGPASSWORD=$DB_PASSWORD psql "sslmode=verify-ca sslrootcert=/root/.postgresql/root.crt sslcert=/root/.postgresql/postgresql.crt sslkey=/tmp/client-key.pem hostaddr=$DB_HOST port=$DB_PORT user=$DB_USERNAME dbname=rm" \
-c "\copy (SELECT row_to_json(t) FROM (SELECT * FROM casev2.event where event_type!='CASE_CREATED' and event_type!='UAC_UPDATED' and event_type!='SAMPLE_LOADED' and event_type!='RM_UAC_CREATED' and event_type!='PRINT_CASE_SELECTED') t) To '$EVENTS_FILE';"


echo "zipping event file"

filename=CensusResponseManagement_events_$(date +"%Y-%m-%dT%H-%M-%S").zip
zip "$filename" "$EVENTS_FILE"

echo "adding $filename to bucket $BUCKET_NAME"
gsutil -q cp "$filename" gs://"$BUCKET_NAME"

echo "write manifest $filename.manifest"

cat > "$filename".manifest <<-EOF
{
  "schemaVersion": 1,
  "files": [
    {
      "sizeBytes": $(stat -c%s $filename),
      "md5sum": "$(openssl md5 "$filename" | awk '{ print $2 }')",
      "relativePath": "./",
      "name": "$filename"
    }
  ],
  "sourceName": "RM",
  "manifestCreated": "$(date +'%Y-%m-%dT%H:%M:%S').0000000Z",
  "description": "RM event table export",
  "dataset": "RM_cases",
  "version": 1
}
EOF

echo "adding $filename.manifest to bucket $BUCKET_NAME"
gsutil -q cp "$filename".manifest gs://"$BUCKET_NAME"

# cleanup files
rm $filename
rm "$filename".manifest
