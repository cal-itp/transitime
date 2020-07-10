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

curl -o /tmp/Core.jar https://storage.googleapis.com/transitclock-resources/core/Core.jar

gcloud builds submit --tag gcr.io/transitclock-282522/rmiregistry
gcloud run deploy --image gcr.io/transitclock-282522/rmiregistry --platform managed --port=1099

--set-env-vars=[KEY=VALUE,...]

Service [rmiregistry] revision [rmiregistry-00002-vob] has been deployed and is serving 100 percent of traffic at https://rmiregistry-sey5ly6w4a-uw.a.run.app

gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=rmiregistry" --project transitclock-282522

gcloud builds submit --tag gcr.io/transitclock-282522/core
gcloud builds submit --tag gcr.io/transitclock-282522/server

ID                                    CREATE_TIME                DURATION  SOURCE                                                                                         IMAGES                                     STATUS
e7fb079c-c266-4650-82f8-425015a25956  2020-07-08T20:59:34+00:00  1M34S     gs://transitclock-282522_cloudbuild/source/1594241508.35-4ad2fedd183042cd90c7abcff968294d.tgz  gcr.io/transitclock-282522/core (+1 more)  SUCCESS

set compute/zone us-west2-c
gcloud config set compute/region us-west2
# --container-env HOME=/home,MODE=test,OWNER=admin
# --tags http-server
# gcloud compute firewall-rules create allow-http --allow tcp:80 --target-tags http-server
gcloud compute firewall-rules create allow-rmi --allow tcp:1099 --target-tags rmi-registry
gcloud compute firewall-rules create allow-secondary-http --allow tcp:8080 --target-tags transitclock-server
gcloud compute instances create-with-container rmi-registry-vm --container-stdin --container-tty --container-image gcr.io/transitclock-282522/rmiregistry --tags rmi-registry

Created [https://www.googleapis.com/compute/v1/projects/transitclock-282522/zones/us-west2-c/instances/rmi-registry-vm].
NAME             ZONE        MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP   STATUS
rmi-registry-vm  us-west2-c  n1-standard-1               10.168.0.2   34.94.24.132  RUNNING


# get container name by first connecting without --container, and then running 'docker ps'
gcloud compute ssh transitclock-core-halifax --container klt-transitclock-core-halifax-bmfr
gcloud compute ssh transitclock-server --container klt-transitclock-server-jtvw

gcloud compute instances stop rmi-registry-vm

gcloud builds submit --tag gcr.io/transitclock-282522/server

### next steps:
- test server locally with RMI host set
- create firewall rule for 8080
- add transitclock-server tp server deploy script
- transitime/gcloud-deply folder:
  + agency-list.txtx
  + deploy.sh:
    o deploy rmiregistry if not already running
    o loop 1 to 100:
      . start sql instance
      . start core
    o start server
- test create-with-container with docker.io/[postgres]
