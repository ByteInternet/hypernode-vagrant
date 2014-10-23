# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "hypernode"
  config.vm.box_url = "http://hypernode.com/vagrant/hypernode.releast-latest.box"

  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 3306, host: 3307

  config.vm.synced_folder "data/web/public/", "/data/web/public", owner: "app", group: "app", create: true
  config.vm.synced_folder "data/web/nginx/", "/data/web/nginx/", owner: "app", group: "app", create: true

  config.vm.provision "shell", path: "vagrant/provisioning/hypernode.sh"
end
