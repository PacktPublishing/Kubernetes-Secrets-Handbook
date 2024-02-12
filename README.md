# Kubernetes Secrets Handbook

<a href="https://www.packtpub.com/product/kubernetes-secrets-handbook/9781805123224?utm_source=github&utm_medium=repository&utm_campaign=9781805123224"><img src="https://content.packt.com/B20970/cover_image_small.jpg" alt="Kubernetes Secrets Handbook" height="256px" align="right"></a>

This is the code repository for [Kubernetes Secrets Handbook](https://www.packtpub.com/product/kubernetes-secrets-handbook/9781805123224?utm_source=github&utm_medium=repository&utm_campaign=9781805123224), published by Packt.

**Design, implement, and maintain production-grade Kubernetes Secrets management solutions**

## What is this book about?

This book covers the following exciting features:
* Explore Kubernetes Secrets, related API objects, and CRUD operations
* Understand the Kubernetes Secrets limitations, attack vectors, and mitigation strategies
* Explore encryption at rest and external secret stores
* Build and operate a production-grade solution with a focus on business continuity
* Integrate a Secrets Management solution in your CI/CD pipelines
* Conduct continuous assessments of the risks and vulnerabilities for each solution
* Draw insights from use cases implemented by large organizations
* Gain an overview of the latest and upcoming Secrets management trends

If you feel this book is for you, get your [copy](https://www.amazon.com/dp/180512322X) today!

<a href="https://www.packtpub.com/?utm_source=github&utm_medium=banner&utm_campaign=GitHubBanner"><img src="https://raw.githubusercontent.com/PacktPublishing/GitHub/master/GitHub.png" 
alt="https://www.packtpub.com/" border="5" /></a>

## Instructions and Navigations
All of the code is organized into folders. For example,

The code will look like the following:
```
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
    - secrets
  providers:
    - aesgcm:
        keys:
          - name: key-20230616
            secret: DlZbD9Vc9ADLjAxKBaWxoevlKdsMMIY68DxQZVabJM8=
    - identity: {}
```

**Following is what you need for this book:**
This handbook is a comprehensive reference for IT professionals to design, implement, operate, and audit Secrets in applications and platforms running on Kubernetes. For developer, platform, and security teams experienced with containers, this Secrets management guide offers a progressive path-from foundations to implementation-with a security-first mindset. You'll also find this book useful if you work with hybrid multi-cloud Kubernetes platforms for organizations concerned with governance and compliance requirements.

With the following software and hardware list you can run all code files present in the book (Chapter 1-14).
### Software and Hardware List
| Chapter | Software required | OS required |
| -------- | ------------------------------------ | ----------------------------------- |
| 1-14 | Docker | Windows, Mac OS X, and Linux (Any) |
| 1-14 | Shell scripting | Windows, Mac OS X, and Linux (Any) |
| 1-14 | Podman and Podman Desktop | Windows, Mac OS X, and Linux (Any) |
| 1-14 | minikube | Windows, Mac OS X, and Linux (Any) |
| 1-14 | Helm | Windows, Mac OS X, and Linux (Any) |
| 1-14 | Terraform | Windows, Mac OS X, and Linux (Any) |
| 1-14 | GCP | Windows, Mac OS X, and Linux (Any) |
| 1-14 | Azure | Windows, Mac OS X, and Linux (Any) |
| 1-14 | AWS | Windows, Mac OS X, and Linux (Any) |
| 1-14 | OKD and Red Hat OpenShif | Windows, Mac OS X, and Linux (Any) |
| 1-14 | StackRox and Red Hat Advanced Cluster Security | Windows, Mac OS X, and Linux (Any) |
| 1-14 | Trivy from Aqua | Windows, Mac OS X, and Linux (Any) |
| 1-14 | HashiCorp Vault | Windows, Mac OS X, and Linux (Any) |

### Related products
* Azure Architecture Explained [[Packt]](https://www.packtpub.com/product/azure-architecture-explained/9781837634811?utm_source=github&utm_medium=repository&utm_campaign=9781837634811) [[Amazon]](https://www.amazon.com/dp/1837634815)

* Azure Architecture Explained [[Packt]](https://www.packtpub.com/product/mastering-elastic-kubernetes-service-on-aws/9781803231211?utm_source=github&utm_medium=repository&utm_campaign=9781803231211) [[Amazon]](https://www.amazon.com/dp/1803231211)


## Get to Know the Author
**Chen Xi**
 is a highly skilled Uber Platform Engineer. As a Tech Leader, he contributed to the Secret and Key Management Platform service, leading and delivering secrets as a service with a 99.99% SLA for thousands of Uber container services across hybrid environments. His cloud infrastructure prowess is evident from his work on Google Kubernetes Engine (GKE) and the integration of Spire-based PKI systems. Prior to joining Uber, he worked at VMware, where he developed microservices for VMware's Hybrid Kubernetes management platform (Tanzu Mission Control) and VMware Kubernetes Engine for multi-cloud (Cloud PKS). Chen is also a contributing author to the Certified Kubernetes Security Specialist (CKS) exam

**Rom Adams**
(né Romuald Vandepoel) is an open-source and C-Suite advisor with 20 years of experience in the IT industry. He is a cloud-native expert who helps organizations to modernize and transform with open-source solutions. He is advising companies and lawmakers on their open- and inner-source strategies. Previously, a Principal Architect at Ondat, a cloud-native storage company acquired by Akamai, where he designed products and hybrid cloud solutions and held roles at Tyco, NetApp, and Red Hat becoming a subject matter expert in hybrid cloud. He was moderator and speaker for several events, sharing his insights on culture, process, technology adoption, and passion about open innovation.

**Emmanouil Gkatziouras**
started his career in software as a Java developer. Since 2015, he has worked daily with cloud providers such as GCP, AWS and Azure, and container orchestration tools such as Kubernetes. He has fulfilled many roles, either in lead positions or as an individual contributor. He enjoys being a versatile engineer and collaborating with development, platform, and architecture teams. He loves to give back to the developer community by contributing to open-source projects and by blogging on various software topics. He is committed to continuous learning and is a holder of certifications such as CKA, CCDAK, PSM, CKAD, and PSO. He is the author of 'A Developer's Essential Guide to Docker Compose'.


## Other books by the authors
[A Developer's Essential Guide to Docker Compose](https://www.packtpub.com/product/a-developers-essential-guide-to-docker-compose/9781803234366?utm_source=github&utm_medium=repository&utm_campaign=9781803234366)

### Download a free PDF

 <i>If you have already purchased a print or Kindle version of this book, you can get a DRM-free PDF version at no cost.<br>Simply click on the link to claim your free PDF.</i>
<p align="center"> <a href="https://packt.link/free-ebook/9781805123224">https://packt.link/free-ebook/9781805123224 </a> </p>
