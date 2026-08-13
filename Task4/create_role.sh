#!/bin/bash
# Script to create additional ClusterRoles for the Kubernetes cluster

set -e

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: security-viewer
rules:
- apiGroups: [""]
  resources: ["secrets", "configmaps", "serviceaccounts"]
  verbs: ["get", "list", "watch"]
EOF

echo "ClusterRole 'security-viewer' created successfully."
