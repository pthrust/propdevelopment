# Поднимите пустой Minikube

```bash
minikube start
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
minikube status
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

# Определите все роли и их полномочия при работе с Kubernetes

# Подготовьте скрипты для создания пользователей

# Подготовьте скрипты, чтобы создать роли

# Подготовьте скрипты, чтобы связать пользователей с ролями