# Запуск Minikube

```bash
> minikube start

😄  minikube v1.38.1 on Ubuntu 26.04
✨  Using the docker driver based on existing profile
👍  Starting "minikube" primary control-plane node in "minikube" cluster
🚜  Pulling base image v0.0.50 ...
🔄  Restarting existing docker container for "minikube" ...
🐳  Preparing Kubernetes v1.35.1 on Docker 29.2.1 ...
🔎  Verifying Kubernetes components...
    ▪ Using image registry.k8s.io/ingress-nginx/controller:v1.14.3
    ▪ Using image registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.6.7
    ▪ Using image registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.6.7
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🔎  Verifying ingress addon...
🌟  Enabled addons: storage-provisioner, ingress, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

```bash
> minikube status

minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

# Роли и их полномочия при работе с Kubernetes

| Роль | Права роли | Группы пользователей |
|---|---|---|
| cluster-admin (встроенная) | Полный доступ ко всем ресурсам кластера: управление узлами, пространствами имён, CRD, политиками безопасности, обновлениями и т.д | ops-admins (администраторы эксплуатации) |
| security-viewer (создаётся) | Просмотр (get, list, watch) секретов, ConfigMap и ServiceAccount во всех неймспейсах | security-users (инженеры безопасности, аудиторы) |
| view (встроенная) | Только чтение ресурсов (get, list, watch) без доступа к секретам, без права редактирования и без просмотра чувствительных данных | viewers (разработчики, тестировщики, которым нужен только просмотр) |

# Создание пользователей через скрипт

```bash
> chmod +x create_users.sh
> ./create_users.sh

Creating user admin-user1 (group ops-admins)
Certificate request self-signature ok
subject=CN=admin-user1, O=ops-admins
User "admin-user1" set.
Context "admin-user1-context" created.
Creating user admin-user2 (group ops-admins)
Certificate request self-signature ok
subject=CN=admin-user2, O=ops-admins
User "admin-user2" set.
Context "admin-user2-context" created.
Creating user security-user1 (group security-users)
Certificate request self-signature ok
subject=CN=security-user1, O=security-users
User "security-user1" set.
Context "security-user1-context" created.
Creating user security-user2 (group security-users)
Certificate request self-signature ok
subject=CN=security-user2, O=security-users
User "security-user2" set.
Context "security-user2-context" created.
Creating user security-user3 (group security-users)
Certificate request self-signature ok
subject=CN=security-user3, O=security-users
User "security-user3" set.
Context "security-user3-context" created.
Creating user viewer-user1 (group viewers)
Certificate request self-signature ok
subject=CN=viewer-user1, O=viewers
User "viewer-user1" set.
Context "viewer-user1-context" created.
Creating user viewer-user2 (group viewers)
Certificate request self-signature ok
subject=CN=viewer-user2, O=viewers
User "viewer-user2" set.
Context "viewer-user2-context" created.
Creating user viewer-user3 (group viewers)
Certificate request self-signature ok
subject=CN=viewer-user3, O=viewers
User "viewer-user3" set.
Context "viewer-user3-context" created.
Creating user viewer-user4 (group viewers)
Certificate request self-signature ok
subject=CN=viewer-user4, O=viewers
User "viewer-user4" set.
Context "viewer-user4-context" created.
Done! Users have been created.
To switch to a user, run: kubectl config use-context <username>-context

> kubectl config get-users 
NAME
admin-user1
admin-user2
minikube
security-user1
security-user2
security-user3
viewer-user1
viewer-user2
viewer-user3
viewer-user4
```
# Создание ролей через скрипт

```bash
> chmod +x create_role.sh 
> ./create_role.sh 
clusterrole.rbac.authorization.k8s.io/security-viewer created
ClusterRole 'security-viewer' created successfully.

>  kubectl get clusterrole | grep sec
security-viewer      2026-08-13T15:55:48Z
```

# Привязка пользователей к ролями через скрипт

```bash
> chmod +x binding.sh 
> ./binding.sh 
clusterrolebinding.rbac.authorization.k8s.io/ops-admins-binding created
clusterrolebinding.rbac.authorization.k8s.io/security-users-binding created
clusterrolebinding.rbac.authorization.k8s.io/viewers-binding created
ClusterRoleBindings created successfully.

> kubectl get clusterrolebinding | grep binding
ops-admins-binding                                              ClusterRole/cluster-admin                                                          9s
security-users-binding                                          ClusterRole/security-viewer                                                        9s
viewers-binding                                                 ClusterRole/view                                                                   8s
```

# Проверка прав доступа

```bash
> kubectl config use-context viewer-user3-context
Switched to context "viewer-user3-context".
>  kubectl get pods
No resources found in default namespace.
>  kubectl get secrets  
Error from server (Forbidden): secrets is forbidden: User "viewer-user3" cannot list resource "secrets" in API group "" in the namespace "default"
>  kubectl get nodes
Error from server (Forbidden): nodes is forbidden: User "viewer-user3" cannot list resource "nodes" in API group "" at the cluster scope 


> kubectl config use-context security-user2-context
Switched to context "security-user2-context".
>  kubectl get pods
Error from server (Forbidden): pods is forbidden: User "security-user2" cannot list resource "pods" in API group "" in the namespace "default"
>  kubectl get secrets  
No resources found in default namespace.
>  kubectl get nodes
Error from server (Forbidden): nodes is forbidden: User "security-user2" cannot list resource "nodes" in API group "" at the cluster scope


> kubectl config use-context admin-user1-context
Switched to context "admin-user1-context".
>  kubectl get pods
No resources found in default namespace.
>  kubectl get secrets  
No resources found in default namespace.
>  kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   58d   v1.35.1
```

# Удаление добавленных изменеий через скрипт
```bash
> chmod +x cleanup.sh 
> ./cleanup.sh 
Starting cleanup...
Deleting ClusterRole and ClusterRoleBindings...
clusterrole.rbac.authorization.k8s.io "security-viewer" deleted
clusterrolebinding.rbac.authorization.k8s.io "ops-admins-binding" deleted
clusterrolebinding.rbac.authorization.k8s.io "security-users-binding" deleted
clusterrolebinding.rbac.authorization.k8s.io "viewers-binding" deleted
Removing contexts and users from kubeconfig...
Property "contexts.admin-user1-context" unset.
Property "contexts.admin-user2-context" unset.
Property "contexts.security-user1-context" unset.
Property "contexts.security-user2-context" unset.
Property "contexts.security-user3-context" unset.
Property "contexts.viewer-user1-context" unset.
Property "contexts.viewer-user2-context" unset.
Property "contexts.viewer-user3-context" unset.
Property "contexts.viewer-user4-context" unset.
Property "users.admin-user1" unset.
Property "users.admin-user2" unset.
Property "users.security-user1" unset.
Property "users.security-user2" unset.
Property "users.security-user3" unset.
Property "users.viewer-user1" unset.
Property "users.viewer-user2" unset.
Property "users.viewer-user3" unset.
Property "users.viewer-user4" unset.
Deleting certificate files...
Directory ./certs removed.
Switching to minikube context...
Switched to context "minikube".
Cleanup completed successfully.
```