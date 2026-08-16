#!/bin/bash
# Script to bind user groups to roles via ClusterRoleBindings

set -e

# 1. Bind ops-admins group to cluster-admin (full access)
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ops-admins-binding
subjects:
- kind: Group
  name: ops-admins
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF

# 2. Bind security-users group to security-viewer (read secrets, configmaps, serviceaccounts)
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: security-users-binding
subjects:
- kind: Group
  name: security-users
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: security-viewer
  apiGroup: rbac.authorization.k8s.io
EOF

# 3. Bind viewers group to view (read-only access, no secrets)
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: viewers-binding
subjects:
- kind: Group
  name: viewers
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: view
  apiGroup: rbac.authorization.k8s.io
EOF

echo "ClusterRoleBindings created successfully."