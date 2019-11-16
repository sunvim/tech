# Kubernetes PV在Retain策略Released状态下重新分配到PVC恢复数据

## 1. 实验目的和环境说明

原由：在使用`helm update` `stable/sonatype-nexus`从1.6版本更新到1.13版本后，出现PVC删除，重新创建PVC的情况，好在原来PV为Retain。故研究下Retain的PV怎么恢复数据。

实验目的：PVC删除后，PV因Retain策略，状态为Released，将PV内数据恢复成PVC，挂载到POD内，达到数据恢复。

环境说明：

- Kubernetes: 1.12.1
- StorageClass: ceph-rbd
- OS: CentOS7

## 2. 实验过程

准备yaml文件：

```
pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-test
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ceph-rbd 
  resources:
    requests:
      storage: 1Gi
nginx.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx-rbd
spec:
  replicas: 1
  template:
    metadata:
      labels:
        name: nginx
    spec:
      containers:
        - name: nginx
          image: nginx
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 80
          volumeMounts:
            - name: ceph-rbd-volume
              mountPath: "/usr/share/nginx/html"
      volumes:
      - name: ceph-rbd-volume
        persistentVolumeClaim:
          claimName: pvc-test
```

新建pvc、deployment、写入数据并删除pvc操作过程：

```
[root@lab1 test]
total 8
-rw-r--r-- 1 root root 533 Oct 24 17:54 nginx.yaml
-rw-r--r-- 1 root root 187 Oct 24 17:55 pvc.yaml
[root@lab1 test]
persistentvolumeclaim/pvc-test created
[root@lab1 test]
NAME               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-test           Bound    pvc-069c4486-d773-11e8-bd12-000c2931d938   1Gi        RWO            ceph-rbd       7s
[root@lab1 test]
deployment.extensions/nginx-rbd created
[root@lab1 test]
nginx-rbd-7c6449886-thv25           1/1     Running   0          33s
[root@lab1 test]
[root@lab1 test]
ygqygq2
[root@lab1 test]
deployment.extensions "nginx-rbd" deleted
[root@lab1 test]
NAME       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-test   Bound    pvc-069c4486-d773-11e8-bd12-000c2931d938   1Gi        RWO            ceph-rbd       4m10s
[root@lab1 test]
persistentvolumeclaim "pvc-test" deleted
[root@lab1 test]
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM              STORAGECLASS   REASON   AGE
pvc-069c4486-d773-11e8-bd12-000c2931d938   1Gi        RWO            Retain           Released   default/pvc-test   ceph-rbd                4m33s
[root@lab1 test]
```

> 从上面可以看到，pvc删除后，pv变成Released状态。

再次创建同名PVC，查看是否分配原来PV操作过程：

```
[root@lab1 test]
persistentvolumeclaim/pvc-test created
[root@lab1 test]
NAME               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-test           Bound    pvc-f2df48ea-d773-11e8-b6c8-000c29ea3e30   1Gi        RWO            ceph-rbd       19s
[root@lab1 test]
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM              STORAGECLASS   REASON   AGE
pvc-069c4486-d773-11e8-bd12-000c2931d938   1Gi        RWO            Retain           Released   default/pvc-test   ceph-rbd                7m18s
[root@lab1 test]
```

> 从上面可以看到，PVC分配的是新的PV，因为PV状态不是Available。

那怎么才能让PV状态变成Available呢？我们来查看之前的PV：

```
[root@lab1 test]
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    pv.kubernetes.io/provisioned-by: ceph.com/rbd
    rbdProvisionerIdentity: ceph.com/rbd
  creationTimestamp: 2018-10-24T09:56:06Z
  finalizers:
  - kubernetes.io/pv-protection
  name: pvc-069c4486-d773-11e8-bd12-000c2931d938
  resourceVersion: "11752758"
  selfLink: /api/v1/persistentvolumes/pvc-069c4486-d773-11e8-bd12-000c2931d938
  uid: 06b57ef7-d773-11e8-bd12-000c2931d938
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 1Gi
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: pvc-test
    namespace: default
    resourceVersion: "11751559"
    uid: 069c4486-d773-11e8-bd12-000c2931d938
  persistentVolumeReclaimPolicy: Retain
  rbd:
    fsType: ext4
    image: kubernetes-dynamic-pvc-06a25bd3-d773-11e8-8c3e-0a580af400d5
    keyring: /etc/ceph/keyring
    monitors:
    - 192.168.105.92:6789
    - 192.168.105.93:6789
    - 192.168.105.94:6789
    pool: kube
    secretRef:
      name: ceph-secret
      namespace: kube-system
    user: kube
  storageClassName: ceph-rbd
status:
  phase: Released
```

> 从上面可以看到，spec.claimRef这段，仍保留之前的PVC信息。

我们大胆删除spec.claimRef这段。再次查看PV：

```
kubectl edit pv pvc-069c4486-d773-11e8-bd12-000c2931d938
[root@lab1 test]
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
pvc-069c4486-d773-11e8-bd12-000c2931d938   1Gi        RWO            Retain           Available           ceph-rbd                10m
```

> 从上面可以看到，之前的PV `pvc-069c4486-d773-11e8-bd12-000c2931d938`已经变为Available。

再次创建PVC、deployment，并查看数据：

```
new_pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-test-new
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ceph-rbd 
  resources:
    requests:
      storage: 1Gi
new_nginx.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx-rbd
spec:
  replicas: 1
  template:
    metadata:
      labels:
        name: nginx
    spec:
      containers:
        - name: nginx
          image: nginx
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 80
          volumeMounts:
            - name: ceph-rbd-volume
              mountPath: "/usr/share/nginx/html"
      volumes:
      - name: ceph-rbd-volume
        persistentVolumeClaim:
          claimName: pvc-test-new
```

操作过程：

```
[root@lab1 test]
persistentvolumeclaim/pvc-test-new created
[root@lab1 test]
NAME               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-test           Bound    pvc-f2df48ea-d773-11e8-b6c8-000c29ea3e30   1Gi        RWO            ceph-rbd       31m
pvc-test-new       Bound    pvc-069c4486-d773-11e8-bd12-000c2931d938   1Gi        RWO            ceph-rbd       27m
[root@lab1 test]
[root@lab1 test]
nginx-rbd-79bb766b6c-mv2h8          1/1     Running   0          20m
[root@lab1 test]
lost+found  ygqygq2.html
[root@lab1 test]
ygqygq2
```

> 从上面可以看到，新的PVC分配到的是原来的PV `pvc-069c4486-d773-11e8-bd12-000c2931d938`，并且数据完全还在。

## 3. 小结

当前版本Kubernetes PVC存储大小是唯一能被设置或请求的资源，因我们没有修改PVC的大小，在PV的Available状态下，有PVC请求分配相同大小时，PV会被分配出去并绑定成功。     
在PV变成Available过程中，最关键的是PV的`spec.claimRef`字段，该字段记录着原来PVC的绑定信息，删除绑定信息，即可重新释放PV从而达到Available。