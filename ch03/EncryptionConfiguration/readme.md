# Key Value Data

## Setup the environment 
Using either Podman Desktop or Docker Desktop as a container enginer, a ```kind``` cluster can be created to illustrate the Kubernetes KMS provider plugin. Within the ```kindcluster``` folder, you will find: 

- A folder ```encryption``` hosting a ```EncryptionConfiguration``` file which corresponds to the default explicit configuration of the Kubernetes KMS provider.
- A configuration file ```kindconfiguration.yaml``` to create the required cluster. 

Let's go over the different files:
```encryption/configuration.yaml```
```YAML
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
      - secrets
    providers:
      - identity: {}
```
This file provide the basic ```identity``` provider with resulting in no encryption for the Secret data field. 

```kindconfiguration.yaml```
```YAML
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: kind-ch03
nodes:
- role: control-plane
  extraMounts:
    - hostPath: encryption
      containerPath: /etc/kubernetes/encryption
  kubeadmConfigPatches:
  - |
    kind: ClusterConfiguration
    apiServer:
      extraArgs:
        encryption-provider-config: "/etc/kubernetes/encryption/configuration.yaml"
        encryption-provider-config-automatic-reload: "true"
      extraVolumes:
        - name: "encryption"
          hostPath: /etc/kubernetes/encryption/configuration.yaml
          mountPath: /etc/kubernetes/encryption/configuration.yaml
          readOnly: false
          pathType: File
```
The file could be read as follow:
- create a ```kind``` cluster called ```kind-ch03```
- attach the ```encryption``` folder as a local volume
- patch the ```kube-apiserver``` configuration with a set of extra arguments to:
  - enable the Kubernetes KMS provider using the configuration ```/etc/kubernetes/encryption/configuration.yaml```
  - enable the autoreload when the configuration file is modified 
- mount the ```encryption``` folder into the ```kube-apiserver``` container to access the configuration file 

To create the cluster, punch the following command within the ```kindcluster``` folder:
```bash
kind create cluster --config kindconfiguration.yaml
```

resulting within the followings:
```
Creating cluster "kind-ch03" ...
 ✓ Ensuring node image (kindest/node:v1.27.3) 🖼
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-kind-ch03"
You can now use your cluster with:

kubectl cluster-info --context kind-kind-ch03

Not sure what to do next? 😅  Check out https://kind.sigs.k8s.io/docs/user/quick-start/
```

At this stage, you can verify the status of your ```kind``` cluster 

```bash 
kubectl get pods -A
```

resulting within the followings:
```
NAMESPACE            NAME                                              READY   STATUS    RESTARTS   AGE
kube-system          coredns-5d78c9869d-pwpvg                          1/1     Running   0          14m
kube-system          coredns-5d78c9869d-xphtj                          1/1     Running   0          14m
kube-system          etcd-kind-ch03-control-plane                      1/1     Running   0          14m
kube-system          kindnet-8bncz                                     1/1     Running   0          14m
kube-system          kube-apiserver-kind-ch03-control-plane            1/1     Running   0          14m
kube-system          kube-controller-manager-kind-ch03-control-plane   1/1     Running   0          14m
kube-system          kube-proxy-h22fx                                  1/1     Running   0          14m
kube-system          kube-scheduler-kind-ch03-control-plane            1/1     Running   0          14m
local-path-storage   local-path-provisioner-6bc4bddd6b-wtgg8           1/1     Running   0          14m
```

## Identity Provider
Like in chapter 1, let's create a secret and verify it's status:

```bash
kubectl apply -f k8s-secret-01.yaml
```

resulting in: 
```
secret/mysecret created
```

```k8s-secret-01.yaml```
```YAML
apiVersion: v1 
kind: Secret 
metadata: 
  name: mysecret 
type: Opaque 
data: 
  username: YWRtaW4= 
  password: UGFja3QxMjMh
```

Let's dump the etcd content of our Secret ```mysecret```: 
```bash
kubectl -n kube-system exec etcd-kind-ch03-control-plane -- sh -c "ETCDCTL_ENDPOINTS='https://127.0.0.1:2379' ETCDCTL_CACERT='/etc/kubernetes/pki/etcd/ca.crt' ETCDCTL_CERT='/etc/kubernetes/pki/etcd/server.crt' ETCDCTL_KEY='/etc/kubernetes/pki/etcd/server.key' ETCDCTL_API=3 etcdctl get /registry/secrets/default/mysecret" |hexdump -C
``` 

```h
00000000  2f 72 65 67 69 73 74 72  79 2f 73 65 63 72 65 74  |/registry/secret|
00000010  73 2f 64 65 66 61 75 6c  74 2f 6d 79 73 65 63 72  |s/default/mysecr|
00000020  65 74 0a 6b 38 73 00 0a  0c 0a 02 76 31 12 06 53  |et.k8s.....v1..S|
00000030  65 63 72 65 74 12 d1 04  0a 9c 04 0a 08 6d 79 73  |ecret........mys|
00000040  65 63 72 65 74 12 00 1a  07 64 65 66 61 75 6c 74  |ecret....default|
00000050  22 00 2a 24 30 36 34 61  31 61 32 66 2d 66 36 31  |".*$064a1a2f-f61|
00000060  30 2d 34 64 63 36 2d 39  35 34 61 2d 37 33 61 62  |0-4dc6-954a-73ab|
00000070  36 38 62 65 35 32 64 66  32 00 38 00 42 08 08 de  |68be52df2.8.B...|
00000080  f7 f6 a4 06 10 00 62 e8  01 0a 30 6b 75 62 65 63  |......b...0kubec|
00000090  74 6c 2e 6b 75 62 65 72  6e 65 74 65 73 2e 69 6f  |tl.kubernetes.io|
000000a0  2f 6c 61 73 74 2d 61 70  70 6c 69 65 64 2d 63 6f  |/last-applied-co|
000000b0  6e 66 69 67 75 72 61 74  69 6f 6e 12 b3 01 7b 22  |nfiguration...{"|
000000c0  61 70 69 56 65 72 73 69  6f 6e 22 3a 22 76 31 22  |apiVersion":"v1"|
000000d0  2c 22 64 61 74 61 22 3a  7b 22 70 61 73 73 77 6f  |,"data":{"passwo|
000000e0  72 64 22 3a 22 55 47 46  6a 61 33 51 78 4d 6a 4d  |rd":"UGFja3QxMjM|
000000f0  68 22 2c 22 75 73 65 72  6e 61 6d 65 22 3a 22 59  |h","username":"Y|
00000100  57 52 74 61 57 34 3d 22  7d 2c 22 6b 69 6e 64 22  |WRtaW4="},"kind"|
00000110  3a 22 53 65 63 72 65 74  22 2c 22 6d 65 74 61 64  |:"Secret","metad|
00000120  61 74 61 22 3a 7b 22 61  6e 6e 6f 74 61 74 69 6f  |ata":{"annotatio|
00000130  6e 73 22 3a 7b 7d 2c 22  6e 61 6d 65 22 3a 22 6d  |ns":{},"name":"m|
00000140  79 73 65 63 72 65 74 22  2c 22 6e 61 6d 65 73 70  |ysecret","namesp|
00000150  61 63 65 22 3a 22 64 65  66 61 75 6c 74 22 7d 2c  |ace":"default"},|
00000160  22 74 79 70 65 22 3a 22  4f 70 61 71 75 65 22 7d  |"type":"Opaque"}|
00000170  0a 8a 01 e2 01 0a 19 6b  75 62 65 63 74 6c 2d 63  |.......kubectl-c|
00000180  6c 69 65 6e 74 2d 73 69  64 65 2d 61 70 70 6c 79  |lient-side-apply|
00000190  12 06 55 70 64 61 74 65  1a 02 76 31 22 08 08 de  |..Update..v1"...|
000001a0  f7 f6 a4 06 10 00 32 08  46 69 65 6c 64 73 56 31  |......2.FieldsV1|
000001b0  3a a2 01 0a 9f 01 7b 22  66 3a 64 61 74 61 22 3a  |:.....{"f:data":|
000001c0  7b 22 2e 22 3a 7b 7d 2c  22 66 3a 70 61 73 73 77  |{".":{},"f:passw|
000001d0  6f 72 64 22 3a 7b 7d 2c  22 66 3a 75 73 65 72 6e  |ord":{},"f:usern|
000001e0  61 6d 65 22 3a 7b 7d 7d  2c 22 66 3a 6d 65 74 61  |ame":{}},"f:meta|
000001f0  64 61 74 61 22 3a 7b 22  66 3a 61 6e 6e 6f 74 61  |data":{"f:annota|
00000200  74 69 6f 6e 73 22 3a 7b  22 2e 22 3a 7b 7d 2c 22  |tions":{".":{},"|
00000210  66 3a 6b 75 62 65 63 74  6c 2e 6b 75 62 65 72 6e  |f:kubectl.kubern|
00000220  65 74 65 73 2e 69 6f 2f  6c 61 73 74 2d 61 70 70  |etes.io/last-app|
00000230  6c 69 65 64 2d 63 6f 6e  66 69 67 75 72 61 74 69  |lied-configurati|
00000240  6f 6e 22 3a 7b 7d 7d 7d  2c 22 66 3a 74 79 70 65  |on":{}}},"f:type|
00000250  22 3a 7b 7d 7d 42 00 12  15 0a 08 70 61 73 73 77  |":{}}B.....passw|
00000260  6f 72 64 12 09 50 61 63  6b 74 31 32 33 21 12 11  |ord..Packt123!..|
00000270  0a 08 75 73 65 72 6e 61  6d 65 12 05 61 64 6d 69  |..username..admi|
00000280  6e 1a 06 4f 70 61 71 75  65 1a 00 22 00 0a        |n..Opaque.."..|
0000028e
```

The below output shows our Secret and its data field in clear text.

## AESxxx Provider

This provider allows to encrypt the data field using a 32-byte random key that will than be encoded in base64 and reference within the configuration file:

```bash
head -c 32 /dev/urandom | base64
```
resulting in the following output:
```
sfzsUFbNX5NOyPzDrRGvsRcBagO/0h5ifxTMKX5wfDE=
```
NOTE: your output will be different. 

The configuration file will need to be update with the following entry:
```YAML
      - aesgcm:
          keys:
            - name: key1
              secret: sfzsUFbNX5NOyPzDrRGvsRcBagO/0h5ifxTMKX5wfDE=
```

and the entire configuration file should look like: 
```YAML 
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
      - secrets
    providers:
      - aesgcm:
          keys:
            - name: key1
              secret: sfzsUFbNX5NOyPzDrRGvsRcBagO/0h5ifxTMKX5wfDE=
      - identity: {}
```

Replace the entire content of the ```configuration.yaml``` within the ```encryption``` folder with the above which will trigger the followings:   

- ```kube-apiserver``` to reload the file to acknowledge the changes.
- a change in the provider order with the AES provider first leading to the encryption of the Secret data field. 
- if the secret already exists; try to read it with the provided key, if not encrypted used the identity provider to read it.

Let's create a secret and verify it's status:

```bash
kubectl apply -f k8s-secret-02.yaml
```

resulting in: 
```
secret/mysecret-encrypted created
```

```k8s-secret-02.yaml```
```YAML
apiVersion: v1 
kind: Secret 
metadata: 
  name: mysecret-encrypted 
type: Opaque 
data: 
  username: YWRtaW4= 
  password: UGFja3QxMjMh
```

Let's dump the etcd content of our Secret ```mysecret-encrypted```: 
```bash
kubectl -n kube-system exec etcd-kind-ch03-control-plane -- sh -c "ETCDCTL_ENDPOINTS='https://127.0.0.1:2379' ETCDCTL_CACERT='/etc/kubernetes/pki/etcd/ca.crt' ETCDCTL_CERT='/etc/kubernetes/pki/etcd/server.crt' ETCDCTL_KEY='/etc/kubernetes/pki/etcd/server.key' ETCDCTL_API=3 etcdctl get /registry/secrets/default/mysecret-encrypted" |hexdump -C
```

```h
00000000  2f 72 65 67 69 73 74 72  79 2f 73 65 63 72 65 74  |/registry/secret|
00000010  73 2f 64 65 66 61 75 6c  74 2f 6d 79 73 65 63 72  |s/default/mysecr|
00000020  65 74 2d 65 6e 63 72 79  70 74 65 64 0a 6b 38 73  |et-encrypted.k8s|
00000030  3a 65 6e 63 3a 61 65 73  67 63 6d 3a 76 31 3a 6b  |:enc:aesgcm:v1:k|
00000040  65 79 31 3a e9 1d dc 1b  e1 6f a4 f3 77 d6 1b 00  |ey1:.....o..w...|
00000050  14 94 c1 52 0e d0 db 2b  93 f4 1a 16 68 5b 5e 89  |...R...+....h[^.|
00000060  af d1 b4 bc 48 8c 6c 76  a5 9f ed 31 82 d5 d7 d7  |....H.lv...1....|
00000070  9d bd 97 da 61 51 e6 c6  bd e6 89 61 da 36 57 07  |....aQ.....a.6W.|
00000080  e1 b5 73 27 df 95 ea f9  05 4c 6b 2d 35 a5 52 6d  |..s'.....Lk-5.Rm|
00000090  cc 07 4f 69 cc 6c 0e fe  6a 1a aa 81 a0 03 44 2a  |..Oi.l..j.....D*|
000000a0  60 44 e5 e3 bf 77 44 47  11 8a 7c d2 2a a4 f8 f7  |`D...wDG..|.*...|
000000b0  41 98 e6 21 13 e9 3e 45  17 77 06 4e 71 24 06 9e  |A..!..>E.w.Nq$..|
000000c0  f0 9d 6d 1c 88 b1 7f 95  0e 20 a1 b2 6e 7d a7 2e  |..m...... ..n}..|
000000d0  b7 cf 7f b8 30 37 c9 a1  83 19 84 4f d8 fe cf 68  |....07.....O...h|
000000e0  81 00 1d f7 2b f4 92 24  1e 23 39 82 92 17 72 36  |....+..$.#9...r6|
000000f0  97 55 ea 13 1c b8 8e 4b  1f 71 53 48 2c 77 0c 02  |.U.....K.qSH,w..|
00000100  6c eb 38 06 35 21 58 f8  7b 2a 28 5c d1 c0 6b 94  |l.8.5!X.{*(\..k.|
00000110  44 c4 a6 f4 32 7b 4f 8f  15 02 b0 1d 56 cf cd 2f  |D...2{O.....V../|
00000120  23 94 b0 67 da 80 5c ac  a2 d5 86 0e 49 34 4a b7  |#..g..\.....I4J.|
00000130  66 6d 61 2e 3a 45 3b f0  5d 81 cc a8 77 73 39 ef  |fma.:E;.]...ws9.|
00000140  21 31 20 9c 17 c6 f4 32  f2 30 84 e3 89 50 37 36  |!1 ....2.0...P76|
00000150  f7 26 0a 8a 72 e3 48 2b  7e 10 18 9b de 5c dc 49  |.&..r.H+~....\.I|
00000160  73 01 b5 96 43 66 37 97  e7 fe 03 61 aa a1 ac b7  |s...Cf7....a....|
00000170  5d eb 55 7d 65 4e 72 f3  f9 65 53 0f a4 97 7e 4b  |].U}eNr..eS...~K|
00000180  83 d8 2b d9 b5 8d 11 e3  ef b3 c5 b8 4e 98 69 d8  |..+.........N.i.|
00000190  34 41 cb 42 73 39 b8 3e  77 5a 8d 90 8a 90 d5 4c  |4A.Bs9.>wZ.....L|
000001a0  cc 62 d4 07 1c d1 14 84  71 a0 39 52 41 ef 60 1a  |.b......q.9RA.`.|
000001b0  2f a0 90 e5 48 7a 66 b5  5e b1 0f d7 3b 31 ae 35  |/...Hzf.^...;1.5|
000001c0  f9 13 51 3a 49 0f 13 d5  64 c1 4a 9e 71 40 96 f5  |..Q:I...d.J.q@..|
000001d0  d8 d2 3f 5b eb fe 36 18  34 dc fc 08 e5 b6 5d 29  |..?[..6.4.....])|
000001e0  bb d7 cf 86 a6 09 42 56  04 f1 70 c7 22 2c d0 e1  |......BV..p.",..|
000001f0  de 5a c1 04 d4 e2 81 aa  cc ea 3e 30 3b a9 d9 fc  |.Z........>0;...|
00000200  6d 22 2b e6 b2 d9 f4 5f  5f bb a5 37 d7 e5 bc 65  |m"+....__..7...e|
00000210  e2 ad 79 a6 82 cd 1c 96  9e 1a 4c a1 4d 0d e1 59  |..y.......L.M..Y|
00000220  34 eb 69 4f c6 71 4c c2  4f de 62 56 2a 16 3d d5  |4.iO.qL.O.bV*.=.|
00000230  a8 22 17 d6 42 62 2f 4c  23 ea f9 4a 07 43 df a4  |."..Bb/L#..J.C..|
00000240  9e 45 b4 f3 b9 3a 22 82  28 db f9 e5 bf 81 f9 0b  |.E...:".(.......|
00000250  f2 56 4e fd 4f 4e 1d 0d  87 14 66 db 62 41 18 80  |.VN.ON....f.bA..|
00000260  ae db 66 b5 94 44 91 f9  7e e2 4c 12 86 74 58 ea  |..f..D..~.L..tX.|
00000270  62 dc c3 36 70 f6 7d 17  7f 4f d8 09 25 24 2d 6b  |b..6p.}..O..%$-k|
00000280  29 6d 46 de 58 75 2f d5  c3 3d 90 30 e4 8f b3 5e  |)mF.Xu/..=.0...^|
00000290  c3 25 9d 54 b4 5c d6 eb  76 ee 69 ef 76 b6 ca a3  |.%.T.\..v.i.v...|
000002a0  a6 d3 6a 94 be ff 9f 6f  91 a6 40 dc 0c cc 6c f2  |..j....o..@...l.|
000002b0  ee 2c 9c 4d 4c c4 7f d4  62 d8 14 9a 91 11 52 d5  |.,.ML...b.....R.|
000002c0  01 7b 26 24 da c2 9d 1e  0e dc a3 33 57 1b 88 c8  |.{&$.......3W...|
000002d0  15 3e 8d 29 b7 0b 50 5d  73 67 a7 c2 1b 3a 0a     |.>.)..P]sg...:.|
000002df
```

Let's unpack the above. We can observe that the payload is encrypted and there is a reference to the provider type, the key name and the version:
```h
00000000  2f 72 65 67 69 73 74 72  79 2f 73 65 63 72 65 74  |/registry/secret|
00000010  73 2f 64 65 66 61 75 6c  74 2f 6d 79 73 65 63 72  |s/default/mysecr|
00000020  65 74 2d 65 6e 63 72 79  70 74 65 64 0a 6b 38 73  |et-encrypted.k8s|
00000030  3a 65 6e 63 3a 61 65 73  67 63 6d 3a 76 31 3a 6b  |:enc:aesgcm:v1:k|
00000040  65 79 31 3a e9 1d dc 1b  e1 6f a4 f3 77 d6 1b 00  |ey1:.....o..w...|
```

Note that you can still run the same command against the previously created Secret and see that nothing has been changed, it is still clear text. 

```bash
kubectl -n kube-system exec etcd-kind-ch03-control-plane -- sh -c "ETCDCTL_ENDPOINTS='https://127.0.0.1:2379' ETCDCTL_CACERT='/etc/kubernetes/pki/etcd/ca.crt' ETCDCTL_CERT='/etc/kubernetes/pki/etcd/server.crt' ETCDCTL_KEY='/etc/kubernetes/pki/etcd/server.key' ETCDCTL_API=3 etcdctl get /registry/secrets/default/mysecret" |hexdump -C
``` 

You can *replace* an existing Secret with with an encrypted revision by executing the following command:

```bash
kubectl get secrets mysecret -o yaml |kubectl replace -f -
```

resulting in:
```
secret/mysecret replaced
```

and the following dump:
```
kubectl -n kube-system exec etcd-kind-ch03-control-plane -- sh -c "ETCDCTL_ENDPOINTS='https://127.0.0.1:2379' ETCDCTL_CACERT='/etc/kubernetes/pki/etcd/ca.crt' ETCDCTL_CERT='/etc/kubernetes/pki/etcd/server.crt' ETCDCTL_KEY='/etc/kubernetes/pki/etcd/server.key' ETCDCTL_API=3 etcdctl get /registry/secrets/default/mysecret" |hexdump -C
```

```h
00000000  2f 72 65 67 69 73 74 72  79 2f 73 65 63 72 65 74  |/registry/secret|
00000010  73 2f 64 65 66 61 75 6c  74 2f 6d 79 73 65 63 72  |s/default/mysecr|
00000020  65 74 0a 6b 38 73 3a 65  6e 63 3a 61 65 73 67 63  |et.k8s:enc:aesgc|
00000030  6d 3a 76 31 3a 6b 65 79  31 3a df e8 08 09 86 7d  |m:v1:key1:.....}|
00000040  94 3d ee a2 09 e5 95 56  64 3b b9 d7 74 11 82 c3  |.=.....Vd;..t...|
00000050  75 49 66 ae 11 44 88 b8  39 a6 79 99 c6 f2 6c 90  |uIf..D..9.y...l.|
00000060  96 bb f5 73 98 86 c9 53  35 9e 11 92 9b 7a 79 26  |...s...S5....zy&|
00000070  db 8c 1b 51 c7 12 69 47  cb 87 5a 26 1a 96 a9 86  |...Q..iG..Z&....|
00000080  b7 5a b8 7e 8a 20 df 1d  e5 e1 2d 35 c8 46 23 48  |.Z.~. ....-5.F#H|
00000090  5e 55 5a 55 0c f6 ec 33  b7 89 06 a4 e2 1d dd 1e  |^UZU...3........|
000000a0  c7 75 7a be aa 79 c3 45  9a c0 a5 db c6 36 c5 17  |.uz..y.E.....6..|
000000b0  05 49 72 28 a8 c2 40 70  ae ad af a7 f9 e3 b6 b9  |.Ir(..@p........|
000000c0  5e 75 b3 e4 03 d1 7e aa  c3 e2 4d 75 29 19 64 57  |^u....~...Mu).dW|
000000d0  15 48 ac e3 2e 2c 54 7f  19 17 a5 41 d8 55 5c 3b  |.H...,T....A.U\;|
000000e0  cd 28 99 fb 83 48 17 a1  bb ce 6c 5b f4 88 b6 a6  |.(...H....l[....|
000000f0  64 40 10 6e 41 e0 44 c9  70 8b 81 e3 fa a7 ec 23  |d@.nA.D.p......#|
00000100  ad 92 3f 47 67 ea 8c ef  05 61 5b 9b 6c 90 ab 61  |..?Gg....a[.l..a|
00000110  2f 21 4e 05 44 8a d8 3e  10 4e 5c 56 5c 6f 73 16  |/!N.D..>.N\V\os.|
00000120  b1 69 ee f9 98 89 6d c9  ff 0d d9 44 68 0e e4 43  |.i....m....Dh..C|
00000130  15 6f de 8b af 0a be 75  6d 8a c7 38 82 e4 25 54  |.o.....um..8..%T|
00000140  0c 26 26 a7 42 52 05 66  ad 2b 3b 6e 0c 0d 8f 5e  |.&&.BR.f.+;n...^|
00000150  ea 51 ea f4 e6 5d aa 15  72 39 f6 58 00 e7 41 d5  |.Q...]..r9.X..A.|
00000160  46 7c 65 0a 1f 8b 5b ee  2a 29 75 3b 12 03 e7 ee  |F|e...[.*)u;....|
00000170  db 21 44 33 9a 5e 33 98  e5 98 95 0b c8 d6 8b e0  |.!D3.^3.........|
00000180  77 42 14 57 6a e7 ff 18  25 4a 34 ba 87 a6 1e 84  |wB.Wj...%J4.....|
00000190  00 70 86 57 95 64 0d c2  ed 9a ed b1 d2 a4 98 6b  |.p.W.d.........k|
000001a0  6d 15 06 81 fb 18 a7 20  77 b0 6f 28 97 db a0 c7  |m...... w.o(....|
000001b0  ab f7 5f 92 dd 38 4c 56  4b af 04 77 6a 6e b3 fc  |.._..8LVK..wjn..|
000001c0  83 c9 df 0e a0 a4 78 08  ae b4 42 32 79 6d bf 5f  |......x...B2ym._|
000001d0  2b 13 d0 a2 9f 83 76 77  cb 89 ad 58 8e ff ca 10  |+.....vw...X....|
000001e0  4e 64 ce 2c af 7d 05 ef  76 2b c0 87 29 ed e8 17  |Nd.,.}..v+..)...|
000001f0  f4 0a aa 51 f5 9f 46 77  43 fe 33 bc d2 2c e4 7a  |...Q..FwC.3..,.z|
00000200  f8 10 c4 a6 05 d6 c2 68  68 de 9e ca 25 88 3a 8f  |.......hh...%.:.|
00000210  7b 68 ec 35 19 55 14 4e  8a d2 71 38 7f 01 46 b2  |{h.5.U.N..q8..F.|
00000220  09 eb 39 2f d5 b2 1b cd  56 61 72 a8 1b 5b b2 37  |..9/....Var..[.7|
00000230  ac 5e 25 fb a3 24 30 a9  e1 3e 0f ed bc 70 05 b7  |.^%..$0..>...p..|
00000240  0e d9 cf c1 5f 45 b6 1b  0a b5 bf b7 62 2d 05 07  |...._E......b-..|
00000250  3f 38 5e 4f 43 b8 6c fd  d6 b7 87 7e 87 c0 71 31  |?8^OC.l....~..q1|
00000260  63 23 d2 24 4f 36 73 76  f6 6e 97 05 29 fe ba 29  |c#.$O6sv.n..)..)|
00000270  03 80 65 60 f8 af 94 1b  46 6b 53 e2 32 57 c9 a3  |..e`....FkS.2W..|
00000280  22 fa a0 8a cb 92 ac ef  80 18 46 1b 4c 30 f3 26  |".........F.L0.&|
00000290  e2 12 b7 f3 fa 66 a1 72  71 87 5d 74 51 b5 dc c1  |.....f.rq.]tQ...|
000002a0  21 2c d2 10 51 e6 a0 a1  1e d7 a7 27 6b 98 d2 fd  |!,..Q......'k...|
000002b0  9e ec b8 24 9f bb d1 b5  40 3f dc 39 44 ac 06 1c  |...$....@?.9D...|
000002c0  44 9e 0a 9c 2a a3 4a c5  1f a8 ea 84 ec eb 28 2d  |D...*.J.......(-|
000002d0  f0 00 b9 c0 30 0f 8e bc  de d5 ab 89 40 b9 68 f9  |....0.......@.h.|
000002e0  7f fc 61 f2 20 6a 85 73  e7 de ac c9 25 ae ec 0f  |..a. j.s....%...|
000002f0  37 10 f1 bc ff f4 14 68  96 71 55 94 f5 51 4d 29  |7......h.qU..QM)|
00000300  a2 84 d8 8e 7f a4 06 80  55 37 2a 53 8f 98 ed 6b  |........U7*S...k|
00000310  e8 cd e5 a6 fe 62 dd 23  46 7a aa 82 33 70 72 f3  |.....b.#Fz..3pr.|
00000320  c8 48 62 64 4d a4 f2 9e  88 45 29 9b 25 9f 78 1f  |.HbdM....E).%.x.|
00000330  19 54 df b2 3c 4b 9a 07  f6 c9 5e f2 43 28 18 b3  |.T..<K....^.C(..|
00000340  2b ea a9 0e 42 21 b1 d7  93 d5 68 a7 52 17 cb cf  |+...B!....h.R...|
00000350  be 0f 63 79 82 7a fa da  f4 ce b3 21 19 de bc af  |..cy.z.....!....|
00000360  8b a4 d0 93 52 34 e4 10  2e b8 79 11 e6 60 7c a4  |....R4....y..`|.|
00000370  39 fe 03 aa 31 33 69 be  e0 65 c2 a4 83 1b 45 d1  |9...13i..e....E.|
00000380  d9 c5 bb 44 ce 2e 0a                              |...D...|
00000387
```

Now, our previously created Secret has been replaced with an encrypted version using the same provider and key:

```h
00000000  2f 72 65 67 69 73 74 72  79 2f 73 65 63 72 65 74  |/registry/secret|
00000010  73 2f 64 65 66 61 75 6c  74 2f 6d 79 73 65 63 72  |s/default/mysecr|
00000020  65 74 0a 6b 38 73 3a 65  6e 63 3a 61 65 73 67 63  |et.k8s:enc:aesgc|
00000030  6d 3a 76 31 3a 6b 65 79  31 3a df e8 08 09 86 7d  |m:v1:key1:.....}|
```

NOTES:
- Inversing the two providers and replacing the Secret will result in an unencrypted revision stored in etcd.
- All Secret objects can be replaced with the following command ```kubectl get secrets --all-namespaces -o json | kubectl replace -f -```

## KMS Provider Plugin
This provider is leveraging an external KMS like HashiCorp Vault via a plugin, either offered by the vault vendor, the Kubernetes distribution, or by the community. 

In this case, we will be using [trousseau.io](https://trousseau.io) that is a community project and agnostic of any vendor. Troussau is using a modular approach helping with integrating new KMS on top of the currently supported ones being HashiCorp Vault (Community and Enterprise), Azure Key Vault, and AWS Vault. 

