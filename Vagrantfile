# -*- mode: ruby -*-
# vi: set ft=ruby :

PROXY_HTTP_PORT = '30001'
PROXY_HTTPS_PORT = '30002'
TIMEZONE = "Asia/Ho_Chi_Minh"

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

            config.vm.provision "shell", path: "init.sh"

            if opts[:type] != "storage"
                config.vm.provision "docker" do |d|
                    d.post_install_provision "shell", path: "config_docker.sh"
                end


            end

            case opts[:type]
            when "storage"
                config.vm.provision "shell", path: "bootstrap_storage.sh"

            when "lb"
                config.vm.synced_folder ".\\nginx-lb", "/misc_data", type: "virtualbox"
                config.vm.provision "shell" do |s|
                    s.args = ["#{PROXY_HTTP_PORT}", "#{PROXY_HTTPS_PORT}"]
                    s.inline = <<-SHELL
                        export PROXY_HTTP_PORT="$1" PROXY_HTTPS_PORT="$2"
                        envsubst '${PROXY_HTTP_PORT} ${PROXY_HTTPS_PORT}' < /misc_data/nginx.conf.tmpl > /misc_data/nginx.conf
                    SHELL
                end

                config.vm.provision "docker" do |d|
                    d.run "nginx-lb",
                        image: "nginx:stable-alpine",
                        args: "-v /misc_data/nginx.conf:/etc/nginx/nginx.conf:ro -v /misc_data/nginx_log:/var/log/nginx -p 80:#{PROXY_HTTP_PORT} -p 443:#{PROXY_HTTPS_PORT}",
                        restart: "always"
                end

                config.vm.provision "shell" do |s|
                    s.args = "#{TIMEZONE}"
                    s.inline = <<-SHELL
                        docker exec -i nginx-lb /bin/sh -c "apk add tzdata"
                        docker exec -i nginx-lb /bin/sh -c "cp /usr/share/zoneinfo/$1 /etc/localtime"
                        docker exec -i nginx-lb /bin/sh -c "apk del tzdata"
                        docker exec -i nginx-lb /bin/sh -c "date"
                    SHELL
                end

            when "master"
                config.vm.provision "shell", path: "bootstrap_cluster.sh"
                config.vm.provision "shell", path: "bootstrap_master.sh"
                config.vm.synced_folder ".\\data", "/data", type: "virtualbox"

            else
                config.vm.provision "shell", path: "bootstrap_cluster.sh"
                config.vm.provision "shell", path: "bootstrap_worker.sh"

            end

        end

    end

end