# Запуск minikube и simulate_incident.sh 

```bash
> mkdir -p ~/.minikube/files/etc/ssl/certs/
> cp audit-policy.yaml ~/.minikube/files/etc/ssl/certs/
> minikube start --extra-config=apiserver.audit-policy-file=/etc/ssl/certs/audit-policy.yaml --extra-config=apiserver.audit-log-path=-

> sh simulate_incident.sh 
namespace/secure-ops created
Context "minikube" modified.
serviceaccount/monitoring created
pod/attacker-pod created
no
Error from server (Forbidden): secrets is forbidden: User "system:serviceaccount:secure-ops:monitoring" cannot list resource "secrets" in API group "" in the namespace "kube-system"
pod/privileged-pod created
OCI runtime exec failed: exec failed: unable to start container process: exec: "cat": executable file not found in $PATH
command terminated with exit code 127
error: resource mapping not found for name: "" namespace: "" from "audit-policy.yaml": no matches for kind "Policy" in version "audit.k8s.io/v1"
ensure CRDs are installed first
rolebinding.rbac.authorization.k8s.io/escalate-binding created

> kubectl logs -n kube-system kube-apiserver-minikube | grep audit > audit.log
```

# Отчёт по результатам анализа файла audit.log принадлежащему kube-apiserver-minikube

## Подозрительные события

1. Доступ к секретам:
   - Запрос для поиска
   ```bash
   ```
   - Кто: ...
   - Где: ...
   - Почему подозрительно: ...

2. Привилегированные поды:
   - Запрос для поиска
   ```bash
   jq 'select(.objectRef.resource=="pods" and .verb=="create" and .stage=="RequestReceived" and .objectRef.name)' audit.log
   ```
   - Кто: ...
   - Комментарий: ...

3. Использование kubectl exec в чужом поде:
   - Запрос для поиска
   ```bash
   ```
   - Кто: ...
   - Что делал: ...

4. Создание RoleBinding с правами cluster-admin:
   - Запрос для поиска
   ```bash
   ```
   - Кто: ...
   - К чему привело: ...

5. Удаление audit-policy.yaml:
   - Запрос для поиска
   ```bash
   ```
   - Кто: ...
   - Возможные последствия: ...

## Вывод

...


