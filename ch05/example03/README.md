# Chapter 5 - Example 3
## Overview and outcomes
This example provides a walkthrough to enable the auditing capabilities for Secrets and ConfigMap on a Kubernetes cluster. 

The goals are to:

* Enable the audit feature.
* Verifying the audit logs.

## Get your environment ready
First clone the git repository:  
```
git clone https://github.com/PacktPublishing/Kubernetes-Secret-Management-Handbook.git 
```

Verify that the folder is available with your environment:  
```
ls -al
total 16
drwxr-xr-x   4 romdalf  staff   128 May  6 15:55 .
drwxr-xr-x  12 romdalf  staff   384 May  6 15:55 ..
drwxr-xr-x@  7 romdalf  staff   224 May  4 12:16 Kubernetes-Secret-Management-Handbook
```

Go in the folder and the relevant chapter and example:  
```
cd Kubernetes-Secret-Management-Handbook/ch05/example03/
```

## Audit Log 
To enable the Audit policy within Kubernetes, create the file ```audit-secret.yaml``` with the following content:

```yaml
apiVersion: audit.k8s.io/v1 # This is required.
kind: Policy
# Don't generate audit events for all requests in RequestReceived stage.
omitStages:
  - "RequestReceived"
rules:
  # Don't log requests to a configmap called "controller-leader"
  - level: None
    resources:
    - group: ""
      resources: ["configmaps"]
      resourceNames: ["controller-leader"]

  # Log the request body of configmap changes in kube-system.
  - level: Request
    resources:
    - group: "" # core API group
      resources: ["configmaps"]
    # This rule only applies to resources in the "kube-system" namespace.
    # The empty string "" can be used to select non-namespaced resources.
    namespaces: ["kube-system"]

  # Log configmap and secret changes in all other namespaces at the Metadata level.
  - level: Metadata
    resources:
    - group: "" # core API group
      resources: ["secrets", "configmaps"]
```

then configure the API server to load the file by altering its configuration with following flag: 
```
--audit-policy-file audit-secret.yaml
```
then restart your API server or start the provisioning of your Kind cluster with the following configuration:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: kind-ch05
nodes:
- role: control-plane
  extraMounts:
    - hostPath: audit
      containerPath: /etc/kubernetes/audit
  kubeadmConfigPatches:
  - |
    kind: ClusterConfiguration
    apiServer:
      extraArgs:
        audit-policy-file: "/etc/kubernetes/audit/audit-secret.yaml"
        audit-log-path: "/var/log/kubernetes/kube-api-audit.log"
      extraVolumes:
        - name: "audit"
          hostPath: /etc/kubernetes/audit/audit-secret.yaml
          mountPath: /etc/kubernetes/audit/audit-secret.yaml
          readOnly: true
          pathType: File
        - name: "audit-log"
          hostPath: /var/log/kubernetes/
          mountPath: /var/log/kubernetes/
          readOnly: false
          pathType: DirectoryOrCreate
```
then run the following command:
```
kind create cluster --config kindconfiguration.yaml
```
resulting with:
```
Creating cluster "kind-ch05" ...
 ✓ Ensuring node image (kindest/node:v1.27.3) 🖼 
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-kind-ch05"
You can now use your cluster with:

kubectl cluster-info --context kind-kind-ch05

Not sure what to do next? 😅  Check out https://kind.sigs.k8s.io/docs/user/quick-start/
```
then check that the API server has the flag set correctly:
```
kubectl describe -n kube-system pod/kube-apiserver-kind-ch05-control-plane
```
resulting with:
```
...
Containers:
  kube-apiserver:
    Container ID:  containerd://b9bc3554f6358b961bedc6375381850502726a67adc9fd20abddcc051ccbaa58
    Image:         registry.k8s.io/kube-apiserver:v1.27.3
    Image ID:      docker.io/library/import-2023-06-15@sha256:0202953c0b15043ca535e81d97f7062240ae66ea044b24378370d6e577782762
    Port:          <none>
    Host Port:     <none>
    Command:
      kube-apiserver
      --advertise-address=10.89.0.2
      --allow-privileged=true
      --audit-log-path=/var/log/kubernetes/kube-api-audit.log
      --audit-policy-file=/etc/kubernetes/audit/audit-secret.yaml
      --authorization-mode=Node,RBAC
      --client-ca-file=/etc/kubernetes/pki/ca.crt
      --enable-admission-plugins=NodeRestriction
      --enable-bootstrap-token-auth=true
      --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
      --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
      --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
      --etcd-servers=https://127.0.0.1:2379
      --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
      --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key
      --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
      --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt
      --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key
      --requestheader-allowed-names=front-proxy-client
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
      --requestheader-extra-headers-prefix=X-Remote-Extra-
      --requestheader-group-headers=X-Remote-Group
      --requestheader-username-headers=X-Remote-User
      --runtime-config=
      --secure-port=6443
      --service-account-issuer=https://kubernetes.default.svc.cluster.local
      --service-account-key-file=/etc/kubernetes/pki/sa.pub
      --service-account-signing-key-file=/etc/kubernetes/pki/sa.key
      --service-cluster-ip-range=10.96.0.0/16
      --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
      --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
    State:          Running
      Started:      Sun, 15 Oct 2023 22:13:10 +0200
...
Volumes:
  audit:
    Type:          HostPath (bare host directory volume)
    Path:          /etc/kubernetes/audit/audit-secret.yaml
    HostPathType:  File
  audit-log:
    Type:          HostPath (bare host directory volume)
    Path:          /var/log/kubernetes/
    HostPathType:  DirectoryOrCreate
...
```
to retrieve the log file, use the following command (here with podman but works with docker too):
```
podman exec kind-ch05-control-plane cat /var/log/kubernetes/kube-api-audit.log > kube-api-audit.log
```
resulting in the creation of file ```kube-api-audit.log``` locally on your computer. A copy of the file related to this example is available in this folder.

Here is an extract:
```JSON
{"kind":"Event","apiVersion":"audit.k8s.io/v1","level":"Metadata","auditID":"721b05e1-6848-477c-88ad-fea03ee2d2c2","stage":"ResponseComplete","requestURI":"/api/v1/namespaces/kube-system/secrets/bootstrap-token-abcdef?timeout=10s","verb":"get","user":{"username":"kubernetes-admin","groups":["system:masters","system:authenticated"]},"sourceIPs":["10.89.0.4"],"userAgent":"kubeadm/v1.27.3 (linux/amd64) kubernetes/25b4e43","objectRef":{"resource":"secrets","namespace":"kube-system","name":"bootstrap-token-abcdef","apiVersion":"v1"},"responseStatus":{"metadata":{},"status":"Failure","message":"secrets \"bootstrap-token-abcdef\" not found","reason":"NotFound","details":{"name":"bootstrap-token-abcdef","kind":"secrets"},"code":404},"requestReceivedTimestamp":"2023-10-15T20:40:35.701578Z","stageTimestamp":"2023-10-15T20:40:35.705548Z","annotations":{"authorization.k8s.io/decision":"allow","authorization.k8s.io/reason":""}}
{"kind":"Event","apiVersion":"audit.k8s.io/v1","level":"Metadata","auditID":"d2b646d3-9107-4afc-ab8d-7608056f4e29","stage":"ResponseComplete","requestURI":"/api/v1/namespaces/kube-system/secrets?timeout=10s","verb":"create","user":{"username":"kubernetes-admin","groups":["system:masters","system:authenticated"]},"sourceIPs":["10.89.0.4"],"userAgent":"kubeadm/v1.27.3 (linux/amd64) kubernetes/25b4e43","objectRef":{"resource":"secrets","namespace":"kube-system","name":"bootstrap-token-abcdef","apiVersion":"v1"},"responseStatus":{"metadata":{},"code":201},"requestReceivedTimestamp":"2023-10-15T20:40:35.709387Z","stageTimestamp":"2023-10-15T20:40:35.715316Z","annotations":{"authorization.k8s.io/decision":"allow","authorization.k8s.io/reason":""}}
{"kind":"Event","apiVersion":"audit.k8s.io/v1","level":"Metadata","auditID":"7784797c-5931-4827-ac3a-f457e2ae7594","stage":"ResponseComplete","requestURI":"/api/v1/namespaces/kube-public/configmaps?timeout=10s","verb":"create","user":{"username":"kubernetes-admin","groups":["system:masters","system:authenticated"]},"sourceIPs":["10.89.0.4"],"userAgent":"kubeadm/v1.27.3 (linux/amd64) kubernetes/25b4e43","objectRef":{"resource":"configmaps","namespace":"kube-public","name":"cluster-info","apiVersion":"v1"},"responseStatus":{"metadata":{},"code":201},"requestReceivedTimestamp":"2023-10-15T20:40:35.754151Z","stageTimestamp":"2023-10-15T20:40:35.758617Z","annotations":{"authorization.k8s.io/decision":"allow","authorization.k8s.io/reason":""}}
```

## Conclusion
**Congratulation! You just enhanced your Kubernetes cluster with auditing capability.
