#! /bin/sh

gcloud compute instances create-with-container rmi-registry \
  --container-stdin --container-tty \
  --container-image gcr.io/transitclock-282522/rmiregistry \
  --boot-disk-size=10GB \
  --tags rmi-registry

