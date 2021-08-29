#!/bin/bash

# The absolute path of the directory where this script is
ROOT_DIR=$(cd $(dirname $0); pwd)

#########
# Setup #
#########

# Setup local certificates
CA_CERTS_FOLDER=$(pwd)/.certs
echo -e "\nSetting up local self-signed CA in ${CA_CERTS_FOLDER}\n"
CAROOT=${CA_CERTS_FOLDER} mkcert -install

# Check if docker is running
echo -e "\nChecking if docker daemon is running\n"
docker ps >/dev/null || (echo -e "\nERROR: Docker daemon is not available\n"; exit 1)

# Create k3d Registry
k3d registry list k3d-gitops-cluster-registry >/dev/null 2>/dev/null ||
  k3d registry create gitops-cluster-registry --port 55000

# Add registry to /etc/hosts
echo -e "\nAdding registry name to /etc/hosts\n"
grep -q "127.0.0.1 k3d-gitops-cluster-registry" /etc/hosts || 
  echo "127.0.0.1 k3d-gitops-cluster-registry" | sudo tee -a /etc/hosts >/dev/null

# Create k3d cluster
echo -e "\nCreating k3d cluster\n"
k3d cluster list gitops-cluster >/dev/null 2>/dev/null ||
  k3d cluster create -c k3d-gitops-cluster.yaml

# Install argocd
argocd/argocd-install/install-argocd.sh -y \
  -f argocd/argocd-install/values-override.yaml

# Create cert-manager namespace
kubectl get ns cert-manager >/dev/null 2>/dev/null || kubectl create namespace cert-manager

# Create local-ca secret
echo -e "\nCreating local-ca secret\n"
kubectl create secret tls \
  --namespace cert-manager \
  local-ca \
  --key=.certs/rootCA-key.pem \
  --cert=.certs/rootCA.pem \
  --dry-run=client -o yaml | kubectl apply -f -
