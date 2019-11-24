# flask-pg-app
![GitHub Actions status](https://github.com/helhindi/flask-pg-app/workflows/docker_lint_build_publish/badge.svg)
![Dockerhub build status](https://img.shields.io/docker/cloud/build/elhindi/flask-pg-app)

## Introduction
A sample flask app with a postgresql backend. The app server can be reached at `/test` and the db at `/test_db`. (see last paragraph explaining how to test)

**Note:** The instructions assume an OSX machine with `brew` installed.

## Getting Started

#### Clone repo & install pre-req tools:
From an OSX machine's Terminal; launch the following commands:
```
  git clone https://github.com/helhindi/flask-pg-app.git &&cd flask-pg-app
```

#### Install `brew`:
```
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
#### Install tools:
Install [`'google-cloud-sdk', 'kubectl', 'terraform', 'skaffold'`] by running:
```
  brew bundle --verbose
```

#### Initialise `gcloud`:
Assuming you've installed `gcloud` (as shown above); init, authenticate and set compute zone interactively via:
```
  gcloud init
```

Enable the following API's:
```
  gcloud services enable storage-api.googleapis.com
  gcloud services enable cloudresourcemanager.googleapis.com
  gcloud services enable compute.googleapis.com
  gcloud services enable container.googleapis.com
  gcloud services enable iam.googleapis.com
```

Create TF service account, generate a key for it and save key location as an `env var`:
```
  gcloud iam service-accounts create terraform \
  gcloud projects add-iam-policy-binding [PROJECT_ID] --member "serviceAccount:terraform@[PROJECT_ID].iam.gserviceaccount.com" --role "roles/owner" \
  gcloud iam service-accounts keys create key.json --iam-account terraform@[PROJECT_ID].iam.gserviceaccount.com \
  export GOOGLE_APPLICATION_CREDENTIALS="$PWD/key.json"
```

Create a GCS bucket for TF state and initialise it:
```
  gsutil mb -l [REGION] gs://[BUCKET_NAME]
  terraform init -backend-config=bucket=[BUCKET_NAME] -backend-config=project=[GOOGLE_PROJECT]
```

#### Initialise Terraform GCP vars:
```
  export TF_VAR_project="$(gcloud config list --format 'value(core.project)')"
  export TF_VAR_region="europe-west2"
```
**Note:** Verify the vars by running:
```
  echo TF_VAR_region=$TF_VAR_region&&echo TF_VAR_project=$TF_VAR_project
```

Also, enter your `gcp_project_id` and `gcp_location` in the `/terraform.tfvars` file.

Now specify an administrative account `user=admin` and set a random password:
```
  export TF_VAR_user="admin"
  export TF_VAR_password="m8XBWryuWEJ238ew"
```

## Initialise and create:
```
  terraform init
  terraform plan
```
Once happy with the above plan output; apply the change using:
```
  terraform apply
```
Once the GKE cluster is up; authenticate and connect to your cluster via `kubectl` and deploy your code using:
```
  skaffold run (or 'skaffold dev' if you want to see code changes deployed immediately)
```

## Test web and db deployments:
Start by port forwarding traffic from `flask-service` to your terminal via:
```
  kubectl port-forward svc/flask-service 80:8080
```
Now to test the `flask` web service; run:
```
  curl localhost:8080/test
```
To test the `postgres` db; run:
```
  curl localhost:8080/test_db
```
