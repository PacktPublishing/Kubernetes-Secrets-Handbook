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
name: kind-ch03
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
      extraVolumes:
        - name: "encryption"
          hostPath: /etc/kubernetes/audit/audit-secret.yaml
          mountPath: /etc/kubernetes/audit/audit-secret.yaml
          readOnly: false
          pathType: File
```
then run the following command:
```
kind create cluster --config kindconfiguration.yaml
```
resulting with:
```

```

## Conclusion
**Congratulation! You just enhanced your Kubernetes cluster with auditing capability.
