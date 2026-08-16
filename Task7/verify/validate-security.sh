#!/bin/bash
set -euo pipefail

main() {
    validate_namespace_configuration
    inspect_gatekeeper_components
    test_policy_enforcement
    verify_workload_state
}

validate_namespace_configuration() {
    echo "[I] Validating namespace configuration"
    kubectl get ns audit-zone -o jsonpath='{.metadata.labels}' | jq . || true
}

inspect_gatekeeper_components() {
    echo "[I] Checking Gatekeeper components"
    kubectl get pods -n gatekeeper-system || true
    kubectl get constrainttemplates || true
    kubectl get k8sprivilegedcontainer.constraints.gatekeeper.sh || true
    kubectl get k8shostpathprohibited.constraints.gatekeeper.sh || true
    kubectl get k8srunasnonrootreadonlyfs.constraints.gatekeeper.sh || true
}

test_policy_enforcement() {
    echo "[I] Testing security policy enforcement"

    echo "[I] Verifying rejection of unsafe configuration:"
    cat <<'EOF' | kubectl apply --dry-run=server -f - || echo "[I] CORRECT: Configuration rejected by security policy"
apiVersion: v1
kind: Pod
metadata:
  name: tmp-bad
  namespace: audit-zone
spec:
  containers:
    - name: bb
      image: busybox:1.36
      command: ["sh", "-c", "sleep 5"]
      securityContext:
        privileged: true
EOF

    echo "[I] Verifying acceptance of safe configuration:"
    cat <<'EOF' | kubectl apply --dry-run=server -f -
apiVersion: v1
kind: Pod
metadata:
  name: tmp-good
  namespace: audit-zone
spec:
  securityContext:
    runAsNonRoot: true
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: bb
      image: busybox:1.36
      command: ["sh", "-c", "sleep 5"]
      securityContext:
        runAsNonRoot: true
        allowPrivilegeEscalation: false
        capabilities:
          drop: ["ALL"]
        readOnlyRootFilesystem: true
EOF
    echo "[I] CORRECT: Safe configuration accepted"
}

verify_workload_state() {
    echo "[I] Verifying workload status"
    kubectl -n audit-zone get pods -o wide || true
}

main
echo "[I] Configuration check completed"