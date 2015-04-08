# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.forward_agent = true

  config.vm.box = "hypernode"
  config.vm.box_url = "http://vagrant.hypernode.com/catalog.json"

  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 3306, host: 3307

  config.vm.synced_folder "data/web/public/", "/data/web/public/", owner: "app", group: "app", create: true
  config.vm.synced_folder "data/web/nginx/", "/data/web/nginx/", owner: "app", group: "app", create: true

  config.vm.provision "shell", path: "vagrant/provisioning/hypernode.sh"

  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true
    config.vm.define 'hypernode' do |node|
      node.vm.hostname = 'xxxxxx-dummy-magweb-vgr.nodes.hypernode.local'
      node.vm.network :private_network, ip: '192.168.33.100'
      node.hostmanager.aliases = %w(example.hypernode.local hypernode-alias)
    end
  end

end
