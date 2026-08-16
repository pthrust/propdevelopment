#!/bin/bash
# Script to clean up all artifacts created in Task 4
# Removes ClusterRoles, ClusterRoleBindings, user contexts, and certificate files

set -e

echo "Starting cleanup..."

# 0. Switch back to the default minikube context
echo "Switching to minikube context..."
kubectl config use-context minikube 2>/dev/null || true

# 1. Delete ClusterRole and ClusterRoleBindings
echo "Deleting ClusterRole and ClusterRoleBindings..."
kubectl delete clusterrole security-viewer --ignore-not-found
kubectl delete clusterrolebinding ops-admins-binding --ignore-not-found
kubectl delete clusterrolebinding security-users-binding --ignore-not-found
kubectl delete clusterrolebinding viewers-binding --ignore-not-found

# 2. Remove user contexts and credentials from kubeconfig
echo "Removing contexts and users from kubeconfig..."
kubectl config unset contexts.admin-user1-context 2>/dev/null || true
kubectl config unset contexts.admin-user2-context 2>/dev/null || true
kubectl config unset contexts.security-user1-context 2>/dev/null || true
kubectl config unset contexts.security-user2-context 2>/dev/null || true
kubectl config unset contexts.security-user3-context 2>/dev/null || true
kubectl config unset contexts.viewer-user1-context 2>/dev/null || true
kubectl config unset contexts.viewer-user2-context 2>/dev/null || true
kubectl config unset contexts.viewer-user3-context 2>/dev/null || true
kubectl config unset contexts.viewer-user4-context 2>/dev/null || true

kubectl config unset users.admin-user1 2>/dev/null || true
kubectl config unset users.admin-user2 2>/dev/null || true
kubectl config unset users.security-user1 2>/dev/null || true
kubectl config unset users.security-user2 2>/dev/null || true
kubectl config unset users.security-user3 2>/dev/null || true
kubectl config unset users.viewer-user1 2>/dev/null || true
kubectl config unset users.viewer-user2 2>/dev/null || true
kubectl config unset users.viewer-user3 2>/dev/null || true
kubectl config unset users.viewer-user4 2>/dev/null || true

# 3. Delete generated certificates and keys
echo "Deleting certificate files..."
if [ -d "./certs" ]; then
    rm -rf ./certs
    echo "Directory ./certs removed."
else
    echo "Directory ./certs not found, skipping."
fi

echo "Cleanup completed successfully."