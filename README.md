Install `eksctl`

Run `eksctl create cluster --name future-air --nodes 3 --region eu-west-2`

brew bundle --verbose

cd aws-ci-demo

verify kubectl version:
kubectl version

helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com





kubectl get secret ecr-credentials-output



# aws-ci-demo
![GitHub Actions status](https://github.com/helhindi/aws-ci-demo/workflows/docker_lint_build_publish/badge.svg)
![Dockerhub build status](https://img.shields.io/docker/cloud/build/elhindi/aws-ci-demo)

## Introduction

The demo provisions an AWS EKS cluster to manage a simple CI/CD pipeline with Jenkins/Sonarqube.

Jenkins is deployed via ![an operator](https://jenkinsci.github.io/kubernetes-operator/docs/) 

The app is a basic flask app with a postgresql backend. The app server can be reached at `/test` and the db at `/test_db`. (see last paragraph explaining how to test)

**Note:** The instructions assumes a Linux/OSX/WSL2 terminal with `brew` installed.

## Getting Started

#### Clone repo & install pre-req tools:
From your Terminal; launch the following commands:
```
  git clone https://github.com/helhindi/aws-ci-demo.git &&cd aws-ci-demo
```

#### Install `brew`:
Mac OS:
```
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
#### Install tools (requires `brew`):
Install [`'awscli', 'eksctl', 'kubectl', 'terraform', 'helm', 'skaffold'`] by running:
```
  brew bundle --verbose
```

#### Initialise `aws`:
Assuming you've configured an aws profile with an associated `administrator ` role policy:
```
  aws configure
```

Create TF service account, generate a key for it and save key location as an `env var`:
```
  Initialise service/cluster role binding
```

(Initialise bucket in code)Create a bucket for TF state and initialise it:
```
  add code to create this
```

#### Initialise Terraform AWS vars:
```
  export TF_VAR_project="$(gcloud config list --format 'value(core.project)')"
  export TF_VAR_region="europe-west2"
```
**Note:** Verify the vars by running:
```
  echo TF_VAR_region=$TF_VAR_region&&echo TF_VAR_project=$TF_VAR_project
```

Also, enter your `aws_project_id` and `aws_location` in the `/terraform.tfvars` file.

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
