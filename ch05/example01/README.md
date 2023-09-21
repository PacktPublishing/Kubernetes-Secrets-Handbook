# Chapter 5 - Example 1
## Overview and outcomes
This example provides a walkthrough to run kube-bench to assess the current security posture of a Kubernetes cluster. 

The goals are to:

* Set up a job a specific control.
* Set up a job for a complete CIS benchmark.
* Recover the outputs and consider the mitigation paths.

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

There are 5 items:    

* Dockerfile; a build manifest to instruct Podman the steps to compil the Golang code into a binary and build the container image.
* hello; a folder containing the ```main.go``` file containing the code of our "Hello World".
* images; all the screenshot for this how-to file.
* k8s-hello_world-ingress.yaml; the Kubernetes Service file to access the "Hello World" application for the outside world. 
* k8s-hello_world.yaml; the Kubernetes Pod deployment file for our "Hello World" application.
* readme.md; this how-to file.

## Kube-Bench
### Single control job


### Full CIS benchmark


### Output and mitigation paths


## Conclusion
**Congratulation! You just ran your first set of security exposure jobs.** 

