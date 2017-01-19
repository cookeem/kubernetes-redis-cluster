# How to run redis cluster on kubernetes

---

### Prerequisites

- Install minikube or kubernetes

Follow this guide: [Install minikube on local machine](https://kubernetes.io/docs/getting-started-guides/minikube/)

Follow this guide: [Install kubernetes by kubeadm on cluster](https://kubernetes.io/docs/getting-started-guides/kubeadm/)

- Install docker-engine

Follow this guide: [Install Docker and run hello-world](https://docs.docker.com/engine/getstarted/step_one/)

---

### Build the redis cluster image

- Use docker to build redis cluster image

```sh
$ docker build docker-images-redis-ruby/ -t redis:ruby
```

- Deploy 6 nodes redis cluster to kubernetes, it will create 6 pods and 6 service in kubernetes.

Redis service port 7000, but we must enable 17000 port to make create redis cluster work!

```sh
$ kubectl create -f redis-cluster/
service "redis-node1-svc" created
deployment "redis-node1" created
service "redis-node2-svc" created
deployment "redis-node2" created
service "redis-node3-svc" created
deployment "redis-node3" created
service "redis-node4-svc" created
deployment "redis-node4" created
service "redis-node5-svc" created
deployment "redis-node5" created
service "redis-node6-svc" created
deployment "redis-node6" created
```

Check the pods:

```sh
$ kubectl get pods -l app=redis
NAME                           READY     STATUS    RESTARTS   AGE
redis-node1-2942478609-lqk6j   1/1       Running   0          39s
redis-node2-3398347028-rg8g0   1/1       Running   0          38s
redis-node3-3854215447-6tsjz   1/1       Running   0          38s
redis-node4-16099610-rknp9     1/1       Running   0          38s
redis-node5-471968029-c7hd0    1/1       Running   0          38s
redis-node6-927836448-d2d0t    1/1       Running   0          37s
```

Use ssh to connect pod container, copy the shell in start-cluster.sh, and run it in container:
```sh
$ kubectl exec -ti redis-node1-2942478609-lqk6j -- /bin/bash
root@redis-node1-2942478609-lqk6j:/data# echo 'yes' | /root/redis-trib.rb create --replicas 1 \                        
> `getent hosts redis-node1-svc | awk '{ print $1 }'`:7000 \
> `getent hosts redis-node2-svc | awk '{ print $1 }'`:7000 \
> `getent hosts redis-node3-svc | awk '{ print $1 }'`:7000 \
> `getent hosts redis-node4-svc | awk '{ print $1 }'`:7000 \
> `getent hosts redis-node5-svc | awk '{ print $1 }'`:7000 \
> `getent hosts redis-node6-svc | awk '{ print $1 }'`:7000 \
> `getent hosts redis-node6-svc | awk '{ print $1 }'`:7000
>>> Creating cluster
>>> Performing hash slots allocation on 7 nodes...
Using 3 masters:
10.0.0.134:7000
10.0.0.99:7000
10.0.0.157:7000
Adding replica 10.0.0.62:7000 to 10.0.0.134:7000
Adding replica 10.0.0.201:7000 to 10.0.0.99:7000
Adding replica 10.0.0.149:7000 to 10.0.0.157:7000
Adding replica 10.0.0.134:7000 to 10.0.0.134:7000
S: a678b2e1acb26a9ddcb2200895614ebc028da621 10.0.0.201:7000
   replicates 436870b83b9cbc14dc1edfc3ca5210c265ad5500
S: 63a60d597ed30c333b8abffe27f399d2a827d7e5 10.0.0.149:7000
   replicates 460a9f8276f1756953364d61c5b50bcf0a519e2d
S: c247aac89ad61f52651eb5506afc7d1761066f54 10.0.0.62:7000
   replicates 7dfbe35cbd42719e2e4688147fb7b4bbe6e05ea5
M: 460a9f8276f1756953364d61c5b50bcf0a519e2d 10.0.0.157:7000
   slots:10923-16383 (5461 slots) master
M: 436870b83b9cbc14dc1edfc3ca5210c265ad5500 10.0.0.99:7000
   slots:5461-10922 (5462 slots) master
M: 7dfbe35cbd42719e2e4688147fb7b4bbe6e05ea5 10.0.0.134:7000
   slots:0-5460 (5461 slots) master
S: 7dfbe35cbd42719e2e4688147fb7b4bbe6e05ea5 10.0.0.134:7000
   replicates 7dfbe35cbd42719e2e4688147fb7b4bbe6e05ea5
Can I set the above configuration? (type 'yes' to accept): >>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join..
>>> Performing Cluster Check (using node 10.0.0.201:7000)
S: a678b2e1acb26a9ddcb2200895614ebc028da621 10.0.0.201:7000
   slots: (0 slots) slave
   replicates 436870b83b9cbc14dc1edfc3ca5210c265ad5500
M: 436870b83b9cbc14dc1edfc3ca5210c265ad5500 172.17.0.11:7000
   slots:5461-10922 (5462 slots) master
   1 additional replica(s)
M: 7dfbe35cbd42719e2e4688147fb7b4bbe6e05ea5 172.17.0.12:7000
   slots:0-5460 (5461 slots) master
   1 additional replica(s)
S: 63a60d597ed30c333b8abffe27f399d2a827d7e5 172.17.0.4:7000
   slots: (0 slots) slave
   replicates 460a9f8276f1756953364d61c5b50bcf0a519e2d
S: c247aac89ad61f52651eb5506afc7d1761066f54 172.17.0.6:7000
   slots: (0 slots) slave
   replicates 7dfbe35cbd42719e2e4688147fb7b4bbe6e05ea5
M: 460a9f8276f1756953364d61c5b50bcf0a519e2d 172.17.0.10:7000
   slots:10923-16383 (5461 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

Verify the cluster start correct or not

```sh
root@redis-node1-2942478609-lqk6j:/data# redis-cli -c -h redis-node1-svc -p 7000
redis-node1-svc:7000> set k1 v1
-> Redirected to slot [12706] located at 172.17.0.10:7000
OK
172.17.0.10:7000> set k2 v2
-> Redirected to slot [449] located at 172.17.0.12:7000
OK
172.17.0.12:7000> get k1
-> Redirected to slot [12706] located at 172.17.0.10:7000
"v1"
172.17.0.10:7000> get k2
-> Redirected to slot [449] located at 172.17.0.12:7000
"v2"
172.17.0.12:7000> exit
```