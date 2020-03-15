# -*- mode: ruby -*-
# vi: set ft=ruby :

servers = [
    {
        :name => "k8s-head",
        :type => "master",
        :box => "centos/7",
        :box_version => "1905.1",
        :eth1 => "172.16.15.13",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :name => "k8s-node-1",
        :type => "node",
        :box => "centos/7",
        :box_version => "1905.1",
        :eth1 => "172.16.15.14",
        :mem => "1024",
        :cpu => "1"
    },
    {
        :name => "k8s-node-2",
        :type => "node",
        :box => "centos/7",
        :box_version => "1905.1",
        :eth1 => "172.16.15.15",
        :mem => "1024",
        :cpu => "1"
    },
    {
        :name => "k8s-nfs",
        :type => "storage",
        :box => "centos/7",
        :box_version => "1905.1",
        :eth1 => "172.16.15.16",
        :mem => "1024",
        :cpu => "1"
    },
    {
        :name => "k8s-lb",
        :type => "lb",
        :box => "centos/7",
        :box_version => "1905.1",
        :eth1 => "172.16.15.17",
        :mem => "1024",
        :cpu => "1"
    }
]


Vagrant.configure("2") do |config|

    servers.each do |opts|
        config.vm.define opts[:name] do |config|

            config.vm.box = opts[:box]
            config.vm.box_version = opts[:box_version]
            config.vm.hostname = opts[:name]
            config.vm.network :private_network, ip: opts[:eth1]
            if Vagrant.has_plugin?("vagrant-timezone")
                config.timezone.value = "Asia/Ho_Chi_Minh"
            end

            config.vm.provider "virtualbox" do |v|

                v.name = opts[:name]
            	v.customize ["modifyvm", :id, "--groups", "/k8s lab"]
                v.customize ["modifyvm", :id, "--memory", opts[:mem]]
                v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]

            end

            config.vm.provision "shell",  inline: "yum update -y"

            if opts[:type] != "storage"
                config.vm.provision "docker" do |d|
                    d.post_install_provision "shell", inline: <<-SHELL
                        cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF
                        mkdir -p /etc/systemd/system/docker.service.d
                        systemctl daemon-reload
                        systemctl restart docker
                    SHELL
                end

                config.vm.provision "shell", path: "bootstrap.sh"

            end

            if opts[:type] == "master"
                config.vm.provision "shell", path: "bootstrap_master.sh"
            elsif opts[:type] == "node"
                config.vm.provision "shell", path: "bootstrap_worker.sh"
            elsif opts[:type] == "storage"
                config.vm.provision "shell", path: "bootstrap_storage.sh"
            else
                config.vm.synced_folder ".\\nginx-lb", "/misc_data", type: "virtualbox"
                config.vm.provision "shell", path: "boostrap_lb.sh"
            end

        end

    end

end