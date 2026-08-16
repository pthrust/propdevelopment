#!/usr/bin/env bash
set -euo pipefail

main() {
    print_step "Setting up namespace with 'restricted' security policy"
    kubectl apply -f "01-create-namespace.yaml"

    print_step "Installing Gatekeeper constraint templates"
    kubectl apply -f gatekeeper/constraint-templates/

    print_step "Applying Gatekeeper constraint policies"
    kubectl apply -f gatekeeper/constraints/

    test_negative_scenario
    test_positive_scenario
    verify_workload_status
}

print_step() {
    echo "[I] $1"
}

test_negative_scenario() {
    echo "[I] Verifying rejection of unsafe configurations"
    local validation_result=0
    for manifest_file in insecure-manifests/*.yaml; do
        local manifest_name
        manifest_name="$(basename "$manifest_file")"
        set +e
        local command_output
        command_output="$(kubectl apply -f "$manifest_file" 2>&1)"
        validation_result=$?
        set -e
        if [ $validation_result -eq 0 ]; then
            echo "[-] ${manifest_name} was accepted but should have been rejected. Details:"
            echo "$command_output"
            exit 1
        else
            echo "[I] CORRECT: ${manifest_name} was rejected as expected. Message: $(echo "$command_output" | head -n 2)"
        fi
    done
}

test_positive_scenario() {
    echo "[I] Verifying acceptance of safe configurations"
    for manifest_file in secure-manifests/*.yaml; do
        local manifest_name
        manifest_name="$(basename "$manifest_file")"
        kubectl apply -f "$manifest_file"
        echo "[I] ACCEPTED: ${manifest_name} successfully applied"
    done
}

verify_workload_status() {
    echo "[I] Verifying workload status"
    sleep 3
    kubectl -n audit-zone get pods -o wide
}

main
echo "[I] All checks completed successfully"