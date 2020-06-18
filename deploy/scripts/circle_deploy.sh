#!/usr/bin/env sh

set -e -u -o pipefail

CONFIG_FILE="/tmp/helm_deploy.yaml"

git_sha_tag=$1
environment_name=$2
k8s_token=$3
encryption_key=$ENCRYPTION_KEY

deploy_with_secrets() {
  echo -n "$K8S_CLUSTER_CERT" | base64 -d > .kube_certificate_authority
  kubectl config set-cluster "$K8S_CLUSTER_NAME" --certificate-authority=".kube_certificate_authority" --server="https://api.${K8S_CLUSTER_NAME}"
  kubectl config set-credentials "circleci_${environment_name}" --token="${k8s_token}"
  kubectl config set-context "circleci_${environment_name}" --cluster="$K8S_CLUSTER_NAME" --user="circleci_${environment_name}" --namespace="formbuilder-base-adapter-${environment_name}"
  kubectl config use-context "circleci_${environment_name}"

  helm template deploy/ \
       --set app_image_tag="APP_${git_sha_tag}" \
       --set worker_image_tag="WORKER_${git_sha_tag}" \
       --set environmentName=$environment_name \
       --set encryption_key=$encryption_key \
       > $CONFIG_FILE

  kubectl apply -f $CONFIG_FILE -n formbuilder-base-adapter-$environment_name
}

main() {
 echo "Deploying ${environment_name}"
 deploy_with_secrets
}

main
