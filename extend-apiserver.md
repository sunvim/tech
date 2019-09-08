# 扩展api-server

1、检查前置条件，系统是否支持 admissionregistration.k8s.io 

kubectl api-versions | grep admissionregistration.k8s.io/v1beta1

有结果，则表示支持

2、使用cfssl 生成相关证书

cfssl 使用方法 详见《cfssl 使用手册》

3、创建需要使用webhook的命名空间

kubectl create ns webhook

4、给webhook命名空间打上标签

kubectl label ns webhook webhook=enable

5、创建使用的Secret

kubectl create secret generic  srt-webhook  \

--from-file=key.pem=步骤2中的生成的key  \

--from-file=cert.pem=步骤2中的生成的cert证书 \

--dry-run -o yaml   |  kubectl -n webhook apply -f -

6、注册CertificateSigningRequest

```yaml
apiVersion: certificates.k8s.io/v1beta1

kind: CertificateSigningRequest

metadata:

  name: csr-webhook

spec:

  groups:

  \- system:authenticated

  request: 步骤2中的csr中内容

  usages:

  \- digital signature

  \- key encipherment

  \- server auth
```

7、授权csr-webhook

kubectl certificate approve crr-webhook

8、创建MutatingWebhookConfiguration

```yaml
apiVersion: admissionregistration.k8s.io/v1beta1

kind: MutatingWebhookConfiguration

metadata:

  name: mwconfig-webhook

  labels:

    app: sidecar-injector

webhooks:

  - name:  admission-webhook

    clientConfig:

      service:

        name:  admission-webhook-svc

        namespace: default

        path: "/mutate"

      caBundle: ${kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}'}

    rules:

      - operations: [ "CREATE" ]

        apiGroups: [""]

        apiVersions: ["v1"]

        resources: ["pods"]

    namespaceSelector:

      matchLabels:

        webhook: enabled

```

9 编写代码 部署到集群



