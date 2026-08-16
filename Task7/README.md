# Шаги:

## 1. Создание namespace `audit-zone` с метками для PodSecurity Admission (уровень `restricted`).
```bash
> kubectl apply -f 01-create-namespace.yaml
namespace/audit-zone created
```

## 2. Подготовлены три небезопасных манифеста (привилегированный под, hostPath, root-пользователь) 

- insecure-manifests/01-privileged-pod.yaml  
- insecure-manifests/02-hostpath-pod.yaml  
- insecure-manifests/03-root-user-pod.yaml  

## 3. Проверка валидации манифестов на блокировку

```bash
> kubectl apply -f insecure-manifests/01-privileged-pod.yaml 
Error from server (Forbidden): error when creating "insecure-manifests/01-privileged-pod.yaml": pods "pod-privileged" is forbidden: violates PodSecurity "restricted:latest": privileged (container "nginx" must not set securityContext.privileged=true), allowPrivilegeEscalation != false (container "nginx" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "nginx" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "nginx" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "nginx" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")

> kubectl apply -f insecure-manifests/02-hostpath-pod.yaml 
Error from server (Forbidden): error when creating "insecure-manifests/02-hostpath-pod.yaml": pods "pod-hostpath" is forbidden: violates PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "busybox" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "busybox" must set securityContext.capabilities.drop=["ALL"]), restricted volume types (volume "host" uses restricted volume type "hostPath"), runAsNonRoot != true (pod or container "busybox" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "busybox" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")

> kubectl apply -f insecure-manifests/03-root-user-pod.yaml 
Error from server (Forbidden): error when creating "insecure-manifests/03-root-user-pod.yaml": pods "pod-root" is forbidden: violates PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "alpine" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "alpine" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "alpine" must set securityContext.runAsNonRoot=true), runAsUser=0 (container "alpine" must not set runAsUser=0), seccompProfile (pod or container "alpine" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
```

## 4. Исправленные манифесты

- secure-manifests/01-secure.yaml  
- secure-manifests/02-secure.yaml  
- secure-manifests/03-secure.yaml  


## 5. Настройте OPA Gatekeeper с набором правил:

### Установка OPA gatekeeper

```bash
> kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/refs/heads/release-3.23/deploy/gatekeeper.yaml
namespace/gatekeeper-system created
resourcequota/gatekeeper-critical-pods created
customresourcedefinition.apiextensions.k8s.io/assign.mutations.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/assignimage.mutations.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/assignmetadata.mutations.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/configpodstatuses.status.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/configs.config.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/connectionpodstatuses.status.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/connections.connection.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/constraintpodstatuses.status.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/constrainttemplatepodstatuses.status.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/constrainttemplates.templates.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/expansiontemplate.expansion.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/expansiontemplatepodstatuses.status.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/modifyset.mutations.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/mutatorpodstatuses.status.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/providerpodstatuses.status.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/providers.externaldata.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/syncsets.syncset.gatekeeper.sh created
serviceaccount/gatekeeper-admin created
role.rbac.authorization.k8s.io/gatekeeper-manager-role created
clusterrole.rbac.authorization.k8s.io/gatekeeper-manager-role created
rolebinding.rbac.authorization.k8s.io/gatekeeper-manager-rolebinding created
clusterrolebinding.rbac.authorization.k8s.io/gatekeeper-manager-rolebinding created
secret/gatekeeper-webhook-server-cert created
service/gatekeeper-webhook-service created
deployment.apps/gatekeeper-audit created
deployment.apps/gatekeeper-controller-manager created
poddisruptionbudget.policy/gatekeeper-controller-manager created
mutatingwebhookconfiguration.admissionregistration.k8s.io/gatekeeper-mutating-webhook-configuration created
validatingwebhookconfiguration.admissionregistration.k8s.io/gatekeeper-validating-webhook-configuration created

> kubectl get pods -n gatekeeper-system
NAME                                             READY   STATUS    RESTARTS        AGE
gatekeeper-audit-66bfbd584d-88fm8                1/1     Running   2 (2m19s ago)   2m36s
gatekeeper-controller-manager-5f66bbfbb5-8kqhd   1/1     Running   0               2m36s
gatekeeper-controller-manager-5f66bbfbb5-9xt92   1/1     Running   0               2m36s
gatekeeper-controller-manager-5f66bbfbb5-d867p   1/1     Running   0               2m36s
```

### Настройка правил OPA Gatekeeper

```bash
> kubectl apply -f gatekeeper/constraint-templates/
constrainttemplate.templates.gatekeeper.sh/k8shostpathprohibited created
constrainttemplate.templates.gatekeeper.sh/k8sprivilegedcontainer created
constrainttemplate.templates.gatekeeper.sh/k8srunasnonrootreadonlyfs created

> kubectl apply -f gatekeeper/constraints/
k8shostpathprohibited.constraints.gatekeeper.sh/disallow-hostpath created
k8sprivilegedcontainer.constraints.gatekeeper.sh/disallow-privileged created
k8srunasnonrootreadonlyfs.constraints.gatekeeper.sh/require-runasnonroot-readonlyfs created
```

## Проверка правил

```bash
> sh verify/validate-security.sh 
[I] Validating namespace configuration
{
  "kubernetes.io/metadata.name": "audit-zone",
  "pod-security.kubernetes.io/audit": "restricted",
  "pod-security.kubernetes.io/audit-version": "latest",
  "pod-security.kubernetes.io/enforce": "restricted",
  "pod-security.kubernetes.io/enforce-version": "latest",
  "pod-security.kubernetes.io/warn": "restricted",
  "pod-security.kubernetes.io/warn-version": "latest"
}
[I] Checking Gatekeeper components
NAME                                             READY   STATUS    RESTARTS      AGE
gatekeeper-audit-66bfbd584d-88fm8                1/1     Running   2 (28m ago)   28m
gatekeeper-controller-manager-5f66bbfbb5-8kqhd   1/1     Running   0             28m
gatekeeper-controller-manager-5f66bbfbb5-9xt92   1/1     Running   0             28m
gatekeeper-controller-manager-5f66bbfbb5-d867p   1/1     Running   0             28m
NAME                        AGE
k8shostpathprohibited       18m
k8sprivilegedcontainer      18m
k8srunasnonrootreadonlyfs   18m
NAME                  ENFORCEMENT-ACTION   TOTAL-VIOLATIONS
disallow-privileged   deny                 0
NAME                ENFORCEMENT-ACTION   TOTAL-VIOLATIONS
disallow-hostpath   deny                 0
NAME                              ENFORCEMENT-ACTION   TOTAL-VIOLATIONS
require-runasnonroot-readonlyfs   deny                 0
[I] Testing security policy enforcement
[I] Verifying rejection of unsafe configuration:
Error from server (Forbidden): error when creating "STDIN": pods "tmp-bad" is forbidden: violates PodSecurity "restricted:latest": privileged (container "bb" must not set securityContext.privileged=true), allowPrivilegeEscalation != false (container "bb" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "bb" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "bb" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "bb" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
[I] CORRECT: Configuration rejected by security policy
[I] Verifying acceptance of safe configuration:
pod/tmp-good created (server dry run)
[I] CORRECT: Safe configuration accepted
[I] Verifying workload status
No resources found in audit-zone namespace.
[I] Configuration check completed
```

```bash
> sh verify/verify-admission.sh 
sh verify/verify-admission.sh 
[I] Setting up namespace with 'restricted' security policy
namespace/audit-zone unchanged
[I] Installing Gatekeeper constraint templates
constrainttemplate.templates.gatekeeper.sh/k8shostpathprohibited unchanged
constrainttemplate.templates.gatekeeper.sh/k8sprivilegedcontainer unchanged
constrainttemplate.templates.gatekeeper.sh/k8srunasnonrootreadonlyfs unchanged
[I] Applying Gatekeeper constraint policies
k8shostpathprohibited.constraints.gatekeeper.sh/disallow-hostpath unchanged
k8sprivilegedcontainer.constraints.gatekeeper.sh/disallow-privileged unchanged
k8srunasnonrootreadonlyfs.constraints.gatekeeper.sh/require-runasnonroot-readonlyfs unchanged
[I] Verifying rejection of unsafe configurations
[I] CORRECT: 01-privileged-pod.yaml was rejected as expected. Message: Error from server (Forbidden): error when creating "insecure-manifests/01-privileged-pod.yaml": pods "pod-privileged" is forbidden: violates PodSecurity "restricted:latest": privileged (container "nginx" must not set securityContext.privileged=true), allowPrivilegeEscalation != false (container "nginx" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "nginx" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "nginx" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "nginx" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
[I] CORRECT: 02-hostpath-pod.yaml was rejected as expected. Message: Error from server (Forbidden): error when creating "insecure-manifests/02-hostpath-pod.yaml": pods "pod-hostpath" is forbidden: violates PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "busybox" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "busybox" must set securityContext.capabilities.drop=["ALL"]), restricted volume types (volume "host" uses restricted volume type "hostPath"), runAsNonRoot != true (pod or container "busybox" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "busybox" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
[I] CORRECT: 03-root-user-pod.yaml was rejected as expected. Message: Error from server (Forbidden): error when creating "insecure-manifests/03-root-user-pod.yaml": pods "pod-root" is forbidden: violates PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "alpine" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "alpine" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "alpine" must set securityContext.runAsNonRoot=true), runAsUser=0 (container "alpine" must not set runAsUser=0), seccompProfile (pod or container "alpine" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
[I] Verifying acceptance of safe configurations
pod/pod-secure-no-privileged configured
[I] ACCEPTED: 01-secure.yaml successfully applied
pod/pod-secure-no-hostpath configured
[I] ACCEPTED: 02-secure.yaml successfully applied
pod/pod-secure-nonroot configured
[I] ACCEPTED: 03-secure.yaml successfully applied
[I] Verifying workload status
NAME                       READY   STATUS    RESTARTS   AGE     IP           NODE       NOMINATED NODE   READINESS GATES
pod-secure-no-hostpath     1/1     Running   0          5m47s   10.244.0.8   minikube   <none>           <none>
pod-secure-no-privileged   1/1     Running   0          5m47s   10.244.0.7   minikube   <none>           <none>
pod-secure-nonroot         1/1     Running   0          5m47s   10.244.0.9   minikube   <none>           <none>
[I] All checks completed successfully
```