#!/usr/bin/env bash

# init kubernetes 
kubeadm init --token 123456.1234567890123456 --token-ttl 0 \
  --pod-network-cidr=172.16.0.0/16 \
  --apiserver-advertise-address=192.168.1.10 \
  --kubernetes-version=$1 \
  --cri-socket=unix:///run/containerd/containerd.sock

# config for master node only 
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# raw_address for gitcontent
raw_git="raw.githubusercontent.com/sysnet4admin/IaC/master/manifests" 

# config for kubernetes's network 
kubectl apply -f https://$raw_git/172.16_net_calico_v1.yaml

# install bash-completion for kubectl 
yum install bash-completion -y 

# kubectl completion on bash-completion dir
kubectl completion bash >/etc/bash_completion.d/kubectl

# alias kubectl to k 
echo 'alias k=kubectl' >> ~/.bashrc
echo "alias ka='kubectl apply -f'" >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc

# git clone prom code
git clone https://github.com/SeongJuMoon/rerepo-kafka-handon-lab
mv /home/vagrant/rerepo-kafka-handon-lab $HOME
find $HOME/rerepo-kafka-handon-lab -regex ".*\.\(sh\)" -exec chmod 700 {} \;

# add reloader
cat <<EOF > /usr/local/bin/rerepo-kafka-handon-lab
#!/usr/bin/env bash
rm -rf $HOME/_kafka-handon-lab
git clone https://github.com/seongjumoon/kafka-handon-lab.git $HOME/kafka-handon-lab
find $HOME/kafka-handon-lab -regex ".*\.\(sh\)" -exec chmod 700 {} \;
EOF
chmod 700 /usr/local/bin/rerepo-kafka-handon-lab

# extended k8s certifications all
git clone https://github.com/yuyicai/update-kube-cert.git /tmp/update-kube-cert
chmod 755 /tmp/update-kube-cert/update-kubeadm-cert.sh
/tmp/update-kube-cert/update-kubeadm-cert.sh all
rm -rf /tmp/update-kube-cert
