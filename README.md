# Self Hosted Runners on GKE with ADC using Workload Identity

![Header Logo](https://services.google.com/fh/files/misc/github_gke.png)

## Overview

This example showcases how to deploy GitHub Actions Self Hosted Runners on GKE with Application Default Credentials using Workload Identity.

## Steps to deploy this example

- Step 1: Set the required environment variables.

```sh
$ export PROJECT_ID=<GCP_PROJECT_ID>
$ export CLUSTER_NAME=runner-cluster
$ export GITHUB_TOKEN=<GITHUB_PAT_TOKEN_OF_ORGANIZATION>
```

- Step 2: Enable the required GCP APIs.

```sh
$ gcloud config set project $PROJECT_ID
$ gcloud services enable container.googleapis.com \
    containerregistry.googleapis.com \
    cloudbuild.googleapis.com
```

- Step 3: Build the Docker image for the Self Hosted Runner using CloudBuild.

```sh
$ gcloud builds submit --tag gcr.io/${PROJECT_ID}/runner:latest .
$ gcloud builds submit --tag gcr.io/${PROJECT_ID}/runner-e2e:latest e2e
$ gcloud builds submit --tag gcr.io/${PROJECT_ID}/runner-hub:latest hub-cdapio
```

- Step 4: Create a GKE Cluster and generate kubeconfig.

```sh
$ gcloud container clusters create ${CLUSTER_NAME} \
    --num-nodes=3 --machine-type=c2-standard-8 --enable-autoscaling --min-nodes=0 --max-nodes=15 \
    --enable-autorepair --enable-autoupgrade \
    --workload-pool=${PROJECT_ID}.svc.id.goog
$ gcloud container clusters get-credentials ${CLUSTER_NAME}
```

- Step 5: Create the Google Service Account that will used as ADC within the runner pods.

```sh
$ gcloud iam service-accounts create gke-github-runner-sa --display-name "gke-github-runner-sa"
$ SA_EMAIL=$(gcloud iam service-accounts list --filter="displayName:gke-github-runner-sa" --format='value(email)')
```

Optionally grant the Google Service Account a role.

```sh
$ gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member serviceAccount:$SA_EMAIL \
    --role roles/editor
```

- Step 6: Bind the Google Service Account created in step 5 to a Kubernetes Service Account.

```sh
$ kubectl create serviceaccount gke-github-runner-sa
$ gcloud iam service-accounts add-iam-policy-binding \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:${PROJECT_ID}.svc.id.goog[default/gke-github-runner-sa]" \
    gke-github-runner-sa@${PROJECT_ID}.iam.gserviceaccount.com
$ kubectl annotate serviceaccount \
    gke-github-runner-sa \
    iam.gke.io/gcp-service-account=runner-sa@${PROJECT_ID}.iam.gserviceaccount.com
```

- Step 7: Store the Github Token in a secret and set the image for the deployment.

```sh
$ kubectl create secret generic runner-k8s-secret --from-literal=GITHUB_TOKEN=$GITHUB_TOKEN
$ kustomize edit set image gcr.io/PROJECT_ID/runner:latest=gcr.io/$PROJECT_ID/runner:latest
$ kustomize edit set image gcr.io/PROJECT_ID/runner:latest=gcr.io/$PROJECT_ID/runner-hub:latest
```

- Step 8: Deploy the Self Hosted Runner deployment using Kustomize.

```sh
$ kustomize build build-cdapio | kubectl apply -f -
$ kustomize build build-data-integrations | kubectl apply -f -
$ kustomize build e2e-cdapio | kubectl apply -f -
$ kustomize build e2e-data-integrations | kubectl apply -f -
$ kustomize build hub-cdapio | kubectl apply -f -
```
