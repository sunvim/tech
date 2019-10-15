# 利用kubeadm安装K8S集群

**环境说明**

OS： ubuntu 18.04

## step1：配置宿主机环境

```bash
vi /etc/default/grub 
GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"
update-grub
reboot
```

## step 2：安装docker/kubeadm/kubelet

```bash
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y docker.io kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
```

## step 3: 设置docker为systemd

```bash
vi /etc/docker/daemon.json

{
	 "exec-opts": ["native.cgroupdriver=systemd"]
}
systemctl daemon-reload 
systemctl restart docker
systemctl enable docker
```

## step 4: 初始化系统

```bash
kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address master主机地址 --kubernetes-version 1.15.2
```

## step 5: 安装pod网络插件

```bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# calico
kubectl apply -f https://docs.projectcalico.org/v3.9/manifests/calico.yaml
```

## step 6: 设置节点名称

```bash
kubectl label nodes 节点名称 node-role.kubernetes.io/worker=worker
```

## step 7: 测试集群

```bash
kubectl run  tmp  --rm --image=alpine:3.10.1 --namespace="default" --restart=Never  -it /bin/sh
```







