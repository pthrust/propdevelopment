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

```bash
# Создать json файл, который будет содержать отфильтрованные события
sh prepare_json.sh
```

## Подозрительные события/инциденты

1. **Доступ к секретам**:
   - Запрос для поиска
   ```bash
   jq 'select(.objectRef.resource=="secrets")' audit.log | grep verb | sort | uniq
   ```
   - Кто: kube-apiserver; kube-controller-manager; kubectl
   - Примичание: множественный доступ с использованием команды watch и list

2. **Привилегированные поды**:
   - Запрос для поиска
   ```bash
   jq 'select(.objectRef.resource=="pods" and .verb=="create" and .stage=="RequestReceived" and .objectRef.name)' audit.log
   ```
   - Кто: system:kube-scheduler
   - Поды: attacker-pod; privileged-pod
   - Митигейшн: Ограничить права на создание pods с привилегированным доступом

3. **Использование kubectl exec в чужом поде**:
   - Запрос для поиска
   ```bash
   jq 'select(.objectRef.subresource=="exec")' audit.log
   ```
   - Кто: kubectl
   - Комманды: cat /etc/resolv.conf
   - Что делал: Читает содержимое файла

4. **Создание RoleBinding с правами cluster-admin**:
   - Запрос для поиска
   ```bash
   jq 'select(.objectRef.resource=="rolebindings" and .verb=="create" and .stage=="RequestReceived")' audit.log
   ```
   - Кто: kubeadm, kubectl
   - Пространства: kube-system; secure-ops
   - Митигейшн: Заблокировать возможность создания RoleBinding

5. **Удаление audit-policy.yaml**:
   - Примичание: команда на удаление политик не отработала :( падает с ошибкой
   ```bash
   kubectl apply -f audit-policy.yaml --as=admin
   error: resource mapping not found for name: "" namespace: "" from "audit-policy.yaml": no matches for kind "Policy" in version "audit.k8s.io/v1"
   ensure CRDs are installed first
   ```
   - Возможные последствия: Сложность проведения анализа инцидентов
   - Митигейшн: Запретить действие delete на объекты Policy + какие-то важны объекты

# Вывод

- Основная угроза исходит от пользователя minikube-user, который создал избыточные привилегии для serviceaccount monitoring  
- Политика RBAC не должна позволять обычным пользователям создавать rolebinding с cluster-admin. Необходимо ограничить такие действия через административные роли и ClusterRole с правом bind только для доверенных субъектов  
- Рекомендуется внедрить политику PodSecurity (например, запретить privileged: true) и ограничить доступ к exec в поды для неавторизованных пользователей  

