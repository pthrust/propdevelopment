#!/bin/bash
# Script to create three Kubernetes users with certificates for Minikube

set -e

# Path to Minikube's CA certificates (usually in ~/.minikube)
MINIKUBE_HOME="${HOME}/.minikube"
CA_CRT="${MINIKUBE_HOME}/ca.crt"
CA_KEY="${MINIKUBE_HOME}/ca.key"

if [ ! -f "$CA_CRT" ] || [ ! -f "$CA_KEY" ]; then
    echo "Error: Minikube CA certificates not found in $MINIKUBE_HOME"
    exit 1
fi

# Function to create a user
create_user() {
    local username=$1
    local group=$2
    local outdir="./certs/${username}"
    mkdir -p "$outdir"

    echo "Creating user ${username} (group ${group})"

    # 1. Generate private key
    openssl genrsa -out "${outdir}/${username}.key" 2048

    # 2. Create Certificate Signing Request (CSR)
    openssl req -new -key "${outdir}/${username}.key" \
        -out "${outdir}/${username}.csr" \
        -subj "/CN=${username}/O=${group}"

    # 3. Sign the certificate with the cluster CA
    openssl x509 -req -in "${outdir}/${username}.csr" \
        -CA "$CA_CRT" -CAkey "$CA_KEY" -CAcreateserial \
        -out "${outdir}/${username}.crt" -days 365

    # 4. Set user credentials in kubeconfig
    kubectl config set-credentials "${username}" \
        --client-certificate="${outdir}/${username}.crt" \
        --client-key="${outdir}/${username}.key" \
        --embed-certs=true

    # 5. Create a dedicated context for the user
    kubectl config set-context "${username}-context" \
        --cluster=minikube \
        --user="${username}"
}

# Create three users with corresponding groups
create_user "admin-user1"   "ops-admins"
create_user "admin-user2"   "ops-admins"
create_user "security-user1" "security-users"
create_user "security-user2" "security-users"
create_user "security-user3" "security-users"
create_user "viewer-user1"  "viewers"
create_user "viewer-user2"  "viewers"
create_user "viewer-user3"  "viewers"
create_user "viewer-user4"  "viewers"

echo "Done! Users have been created."
echo "To switch to a user, run: kubectl config use-context <username>-context"