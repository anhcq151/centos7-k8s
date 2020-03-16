# Bootstrap new k8s cluster

This is collection of script to bootstrap new k8s cluster for using as a lab with following components are installed with minimum configuration:
- A separated `nginx` load balancer
- A k8s `nginx` ingress controller
- A `nfs` server acts as storage for k8s cluster

Tools are used:
- Vagrant
- Virtualbox
- kubectl
- helm v3

All boxes are running CentOS 7.

`kubectl` and `helm v3` are installed on master node `k8s-head` but you can install on your workstation, just simply copy `config` file in `~/.kube/config` on `k8s-head` to same location on your workstation.

## Network environment

All hosts are placed under same subnet: `172.16.15.0/24`
- 172.16.15.13 k8s-head
- 172.16.15.14 k8s-node-1
- 172.16.15.15 k8s-node-2
- 172.16.15.16 k8s-nfs
- 172.16.15.17 k8s-lb

## How to use

`CALICO` container network interface is chosen for this provision, which is default to `192.168.0.0/16` range for container network. If you choose other lab network CIDR than `172.16.15.0/24`, take note of this to prevent overlaping with container network.

*Before you begin*

Install Vagrant, Virtualbox on your host workstation and/or install `kubectl`, `helm v3`

1. Clone this repo
    ```
    git clone git@github.com:anhcq151/centos7-k8s.git
    ```

~~2. Edit file `bootstrap_master.sh`:~~
   - ~~Adjust values of variables `PROXY_HTTP_PORT` and `PROXY_HTTPS_PORT` to a number of your choice in range `30000 - 32767`~~

3. Edit file `bootstrap_lb.sh`
   - Adjust values of variables `PROXY_HTTP_PORT` and `PROXY_HTTPS_PORT` to a number of your choice in range `30000 - 32767`
   - Adjust the load balancer timezone to your location, I hard-coded default timezone to `Asia/Ho_Chi_Minh`
   - Adjust value of variable `NAMESPACE` to name of your choice, this is name of k8s namespace where `nginx-ingress` will be installed into.

4. Edit file `Vagrantfile`:
    - Adjust all boxes timezone to your location, I hard-coded default timezone to `Asia/Ho_Chi_Minh`

5. Start provisioning:

    Install Vagrant plugin (recommended)
    ```
    vagrant plugin install vagrant-vbguest vagrant-timezone
    ```
    Bring all up:
    ```
    vagrant up
    ```

6. Install `nginx-ingress`

    Adapt `$NAMESPACE`, `$PROXY_HTTP_PORT` and `$PROXY_HTTPS_PORT` variable to ones set in step 2.

    ```
    docker run -dit --mount type=bind,source=data/config,target=/root/.kube/config --mount type=bind,source=data/install_ingress.sh,target=/root/install_ingress.sh -e NAMESPACE="loadbalancer" -e PROXY_HTTP_PORT="30001" -e PROXY_HTTPS_PORT="30002" --name install_ingress --entrypoint /root/install_ingress.sh quanganh151/kubectl_helm
    ```
>Tested on my workstation: 
>- OS: Windows 10 build 1909 x64
>- vagrant version 2.2.7
>- virtualbox version 6.1.4
>- Shell environment: Ubuntu 18.04 in WSL