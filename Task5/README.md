# Создание подов и сервисов

```bash
> chmod +x ./create_pods.sh 
> kubectl get pods
No resources found in default namespace.

> ./create_pods.sh 
service/front-end-app created
pod/front-end-app created
service/back-end-api-app created
pod/back-end-api-app created
service/admin-front-end-app created
pod/admin-front-end-app created
service/admin-back-end-api-app created
pod/admin-back-end-api-app created

> kubectl get pods
NAME                     READY   STATUS              RESTARTS   AGE
admin-back-end-api-app   0/1     ContainerCreating   0          2s
admin-front-end-app      0/1     ContainerCreating   0          2s
back-end-api-app         0/1     ContainerCreating   0          2s
front-end-app            0/1     ContainerCreating   0          3s

> kubectl get svc
NAME                     TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
admin-back-end-api-app   ClusterIP   10.103.7.41      <none>        80/TCP    73s
admin-front-end-app      ClusterIP   10.105.150.155   <none>        80/TCP    73s
back-end-api-app         ClusterIP   10.110.156.111   <none>        80/TCP    73s
front-end-app            ClusterIP   10.97.69.215     <none>        80/TCP    74s
kubernetes               ClusterIP   10.96.0.1        <none>        443/TCP   59d

```

# Проверка доступности сервисов до установки политик

```bash
> kubectl exec -it front-end-app -- sh
# curl -o /dev/null -s -w "%{http_code}\n" http://back-end-api-app
200
# curl -o /dev/null -s -w "%{http_code}\n" http://admin-back-end-api-app
200

> kubectl exec -it admin-front-end-app -- sh
# curl -o /dev/null -s -w "%{http_code}\n" http://back-end-api-app
200
# curl -o /dev/null -s -w "%{http_code}\n" http://admin-back-end-api-app
200
```

# Создайние сетевх политик non-admin-api-allow.yaml и admin-api-allow.yaml

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: back-end-api-allow
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: back-end-api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: front-end
    ports:
    - port: 80
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: admin-back-end-api-allow
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: admin-back-end-api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: admin-front-end
    ports:
    - port: 80	
```

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: admin-back-end-api-allow
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: admin-back-end-api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: admin-front-end
    ports:
    - port: 80
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: admin-front-end-api-allow
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: admin-front-end
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: admin-back-end-api
    ports:
    - port: 80
```

# Применение сетевой политики

```bash
> kubectl apply -f non-admin-api-allow.yaml
networkpolicy.networking.k8s.io/back-end-api-allow created
networkpolicy.networking.k8s.io/front-end-api-allow created

> kubectl apply -f admin-api-allow.yaml
networkpolicy.networking.k8s.io/admin-back-end-api-allow created
networkpolicy.networking.k8s.io/admin-front-end-api-allow created
```

# Проверка

```bash
> minikube stop 

> minikube start --network-plugin=cni --cni=calico


> kubectl run test-front --image=busybox --labels role=front-end --rm -i -t -- sh

# wget --timeout=2 -S --spider -O /dev/null http://back-end-api-app 2>&1 | grep "HTTP/" | awk '{print $2}'
# 200
# wget --timeout=2 -S --spider -O /dev/null http://admin-back-end-api-app 2>&1 | grep "HTTP/" | awk '{print $2}'
#
#

> kubectl run test-front --image=busybox --labels role=admin-front-end --rm -i -t -- sh
# wget --timeout=2 -S --spider -O /dev/null http://back-end-api-app 2>&1 | grep "HTTP/" | awk '{print $2}'
# 
# wget --timeout=2 -S --spider -O /dev/null http://admin-back-end-api-app 2>&1 | grep "HTTP/" | awk '{print $2}'
# 200
```
 