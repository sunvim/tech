# `Access kubernetes API Server With Restful`

> most time, I want to access the `kubernetes api server` with Restful, because the client library is big, dependency libraries is too much more.
>
> so  I supply  the simple  way  like the below



step 1: create  a service account in the cluster

```bash
kubectl create serviceaccount rest-accessor
```

step 2: create a (Cluster)Role granting access to the necessary resources. I  prefer `ClusterRoles` for roles that are reusable across the system. In  this example I grant access to pods and their logs, which we’ll use in  an example use case later.

```bash
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: rest-accessor
rules:
- apiGroups: [""] 
  resources: ["pods", "configmaps","services", "endpoints","secrets","tokens","deployments","jobs","cronjobs","nodes"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

step 3:  Bind the `ClusterRole` to the `ServiceAccount` in the current name space (ex. default).

```bash
kubectl create rolebinding rest-accessor:rest-accessor --clusterrole rest-accessor --serviceaccount default:rest-accessor
```

step 4: Get the Bearer Token, Certificate and `api server` URL

```bash
 # Get the ServiceAccount's token Secret's name
SERVICE_ACCOUNT=rest-accessor
# Extract the Bearer token from the Secret and decode
SECRET=$(kubectl get serviceaccount ${SERVICE_ACCOUNT} -o json | jq -Mr '.secrets[].name | select(contains("token"))') 
# Extract, decode and write the ca.crt to a temporary location
TOKEN=$(kubectl get secret ${SECRET} -o json | jq -Mr '.data.token' | base64 -d)
# Get the API Server location
kubectl get secret ${SECRET} -o json | jq -Mr '.data["ca.crt"]' | base64 -d > ./client-ca.crt
APISERVER=https://$(kubectl -n default get endpoints kubernetes --no-headers | awk '{ print $2 }')
```

step 5: test 

```bash
curl -s $APISERVER/openapi/v2  --header "Authorization: Bearer $TOKEN" --cacert ./client-ca.crt  | jq
```



