# Chapter 5 - Example 1
## Overview and outcomes
This example provides a walkthrough to run kube-bench to assess the current security posture of a Kubernetes cluster. 

The goals are to:

* Set up a job a specific control.
* Set up a job for a complete CIS benchmark.
* Recover the outputs.

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
cd Kubernetes-Secret-Management-Handbook/ch05/example01/
```

We will be using a standard Kind cluster deployed via Podman Desktop on a MacBook Pro M1. 

## compliance operator


## Conclusion
**Congratulation! You just ran your first set of security exposure jobs.** 

