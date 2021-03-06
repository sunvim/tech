# 利用minikube部署测试Istio

**配置minikube**

```bash
minikube config set vm-driver kvm2
```

**安装启动K8S**

```bash
minikube start --memory=4096 --cpus=4 --kubernetes-version=v1.15.2
```

配置minikube提供loadbalance服务

```bash
 minikube tunnel
```

部署istio 2.14.3

```bash
#初始化CRD
helm install istio/install/kubernetes/helm/istio-init --name istio-init --namespace istio-system
#检查初始化结果
kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l
#部署Istio
helm install istio/install/kubernetes/helm/istio --name istio --namespace istio-system

```

