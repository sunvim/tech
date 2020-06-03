# 创建特别的Context用户使用权限 `Kubernetes`

- 生成用户的私钥文件

  ```bash
  mkdir matic
  openssl genrsa -out matic.key 2048
  ```

  

- 使用私钥生成一个认证签名请求文件

  ```bash
  openssl req -new -key matic.key -out matic.csr -subj "/CN=matic/O=matic"
  ```

- 创建`Kubernetes Certificate Signing Request`的`signing-request.yaml`文件，然后将认证签名文件作base64编码后插入到`yaml`文件中，最后通过命令创建Certificate Signing Request资源。

  ```bash
      signing-request.yaml 
  apiVersion: certificates.k8s.io/v1beta1
  kind: CertificateSigningRequest
  metadata:
    name: matic-csr
  spec:
    groups:
    - system:authenticated
  
    request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5akNDQWJLZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQ0FYRFRJd01ERXlOVEF6TkRVek5Wb1lEekl4TVRrd01UQXhNRE0wTlRNMVdqQVZNUk13RVFZRApWUVFERXdwcmRXSmxjbTVsZEdWek1JSUJJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBUThBTUlJQkNnS0NBUUVBCndtVTBsUEpvRDlrYjE5Y2Y0alJ5U3BVS2RKV0tlZFR4NXU5bGY5N3RQZzBIM2JQSCtNa3BIT2cyNS9GL2ZWVlUKZ3gyRW5FTkVwNFBjTVFwWFAza0NPUXFOSENYUDBXKzd3M2ZucGNkeG5nZTdETFc0U0VnVE9XVy9zamN3dm1OTgo4MktWanpxRkgvWS8vVXVYZjlkYXNZLzhrUVRkNTVvd0FzcDBKRGFsdk5rT0MxcGtsb2VKc0czYjFQWkdOWDc5CkJOTktpN0tqN2tjVDg0aDVlTDFGaUI0K3NyQXQ2OFdmNEZVUDR0bEMwREdQZ2lzRmNXR1ZLRGZCOG12RTlVYmMKb1p5WXdjV2s2NmJ6UGhaNnc5ZTByNmZtdng4WDQxMEpsa0t0aW9WQnhEazZDemU2cytxZ1piZXA4RzVmWWVlWgpCOHFJMjByNHgrQWhPenVSS092a2VRSURBUUFCb3lNd0lUQU9CZ05WSFE4QkFmOEVCQU1DQXFRd0R3WURWUjBUCkFRSC9CQVV3QXdFQi96QU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFvelFoR3RrQXNhRXV3QzRTK25DaUVTV1YKeXZVUUh4MGFPbGpkUFA4US9rQzVMdnlBSlZRK2I0ZzJHYk44MnZ5NkN6dnQrcVRIbFV5dm0wVm9YcFMrWWQ5MgpoMlBKS25MMS9CQjFNeW9WU0E5bGMweGhrbjRhNndhMGpTaW52KzhZdDVkcVRJRitOSjkxQ2VsTWx4Q1BRYm94CnI3SkxWaWtjOWszc00wYjBLRjJMS05pUnhNNktkVzZwUVRrVi9ldkFJL2RNYWZkRi9oTTBaM054KzJZQlNjR08KMlA2anJnQm1xeHZZUmpoQlZ2VE9KcjlDYkNlMkhWTm5GUTcyb3cyZ2dVNERvVHJscTAzbmRwWDBSKzJTeFo2UAowOTNPcVJ2cnlpcW14TjdhdmdEeExiOWc1QTMvY1RBT25JczFPSkJHY2dYZlVHRTN5TlNjVU91YjB0UGljdz09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
  
    usages:
    - digital signature
    - key encipherment
    - server auth
  
  ```

  