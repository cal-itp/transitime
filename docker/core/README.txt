to update docker image for google cloud deployment:

- gcloud config set project transitclock-282522 
- gcloud builds submit --tag gcr.io/transitclock-282522/core

Note that ../../transitclock/target/Core.jar is not included
in the docker image, but rather stored at:

gs://transitclock-resources/core/Core.jar

To update, run:

gsutil cp ../../transitclock/target/Core.jar gs://transitclock-resources/core/Core.jar 

Link is accessible publicly at https://storage.googleapis.com/transitclock-resources/core/Core.jar
