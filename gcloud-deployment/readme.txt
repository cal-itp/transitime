- create gcloud project, such as 'transitclock'
- set as active project

gcloud sql instances create transitclock-postgres-test --database-version=POSTGRES_9_6 \
       --cpu=1 --memory=3840MB \
       --region=us-west2

gcloud sql users set-password postgres --instance=transitclock-postgres-test --password=[password]

- list sql instances with 'gcloud sql instances list'

NAME                        DATABASE_VERSION  LOCATION    TIER              PRIMARY_ADDRESS  PRIVATE_ADDRESS  STATUS
transitclock-postgres-test  POSTGRES_9_6      us-west2-a  db-custom-1-3840  34.94.231.127    -                RUNNABLE


gsutil mb -l US-WEST2 on gs://transitclock-resources/

curl -X GET \
  -o start-registry.sh \
  https://storage.googleapis.com/storage/v1/b/transitclock-resources/o/start-registry.sh?alt=media

gcloud builds submit --tag gcr.io/transitclock-282522/rmiregistry
gcloud run deploy --image gcr.io/transitclock-282522/rmiregistry --platform managed --port=1099

--set-env-vars=[KEY=VALUE,...]

Service [rmiregistry] revision [rmiregistry-00002-vob] has been deployed and is serving 100 percent of traffic at https://rmiregistry-sey5ly6w4a-uw.a.run.app

gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=rmiregistry" --project transitclock-282522


### next steps:
- check with port AbstractServer starts on?
- eliminate need for docker/core/go.sh
- transitime/gcloud-deply folder:
  + agency-list.txtx
  + deploy.sh:
    o deploy rmiregistry if not already running
    o loop 1 to 100:
      . start sql instance
      . start core
    o start server
