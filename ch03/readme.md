# Encrypting Secret in-transit and at-rest

## Content
This folder provides you with a walkthrough the implementation of the Kubernetes ```EncryptionConfiguration``` capabilities for the *Chapter 3* of Kubernetes Secrets Handbook.  

## Technical Requirements
Like in *Chapter 1*, we will be using the followings:

- [Homebrew](https://brew.sh)
- [Git](https://git-scm.com)
- [Golang](https://go.dev)
- [kind](https://kind.sigs.k8s.io/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/)
- [Podman](https://podman.io) and [Podman Desktop](https://podman-desktop.io)

Don't worry, you don't need to install each pieces indiviually, we will be using ```brew``` to do so. 

### Install brew

As [homebrew.io](https://brew.sh/) shows, run the following command from your terminal:
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Note: While Homebrew is a well-known project, you should never trust to run a script from the Internet. Make sure to review it before hand.

### Install everything else

Thanks to ```brew``` to deploy the remaning of the hands-on environment, you can run the following command:

```
brew install git
brew install go
brew install kind 
brew install kubernetes-cli
brew install podman
brew install podman-desktop
```
