# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'
require 'fileutils'

# source local config
unless File.exist?('local.yml')
    FileUtils.cp('local.example.yml', 'local.yml')
end
settings = YAML.load_file 'local.yml'

if settings['php'].nil? or settings['php']['version'].nil?
    settings_php_version = 5.5
end
php_version = ENV['HYPERNODE_VAGRANT_PHP_VERSION'] ? ENV['HYPERNODE_VAGRANT_PHP_VERSION'] : settings_php_version

available_php_versions = [5.5, 7.0]
unless available_php_versions.include?(php_version)
        abort "Configure an available php version in local.yml: #{available_php_versions.join(', ')}. You specified: #{php_version}"
end

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# paths to local settings file
SETTINGS_FILE = "local.yml"
SETTINGS_EXAMPLES_FILE = "local.example.yml"

# abort if vagrant-vbguest is not installed
if !Vagrant.has_plugin?("vagrant-vbguest")
  abort "Please install the 'vagrant-vbguest' module"
end

# abort if vagrant-hostmanager is not installed
if !Vagrant.has_plugin?("vagrant-hostmanager")
  abort "Please install the 'vagrant-hostmanager' module"
end

# source local config
unless File.exist?(SETTINGS_FILE)
  FileUtils.cp(SETTINGS_EXAMPLES_FILE, SETTINGS_FILE)
end
settings = YAML.load_file SETTINGS_FILE

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.forward_agent = true

  if php_version == 7.0
    config.vm.box = 'hypernode_php7'
    config.vm.box_url = 'http://vagrant.hypernode.com/customer/php7/catalog.json'
  else
    config.vm.box = 'hypernode_php5'
    config.vm.box_url = 'http://vagrant.hypernode.com/customer/php5/catalog.json'
  end

  config.vm.network "private_network", type: "dhcp"
  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
  config.vm.network "forwarded_port", guest: 3306, host: 3307, auto_correct: true

  if !settings['fs']['folders'].nil?
    settings['fs']['folders'].each do |name, folder|
      config.vm.synced_folder folder['host'], folder['guest'], type: settings['fs']['type'], create: true, owner: "app", group: "app"
    end
  end

  config.vm.provision "shell", path: "vagrant/provisioning/hypernode.sh"

  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true

    # Get the dynamic hostname from the running box so we know what to put in 
    # /etc/hosts even though we don't specify a static private ip address
    # For more information about why this is necessary see:
    # https://github.com/smdahlen/vagrant-hostmanager/issues/86#issuecomment-183265949
    config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
      if vm.communicate.ready?
        result = ""
        vm.communicate.execute("ifconfig eth1") do |type, data|
          result << data if type == :stdout
        end
      end
      (ip = /inet addr:(\d+\.\d+\.\d+\.\d+)/.match(result)) && ip[1]
    end

    config.vm.define 'hypernode' do |node|
      # Name the vagrant box after the directory the Vagrantfile is in. If the Vagrantfile
      # is in a directory named 'hypernode-vagrant' assume the name of the parent directory.
      # This is so there is a human readable difference between multiple test environments. 
      working_directory = File.basename(Dir.getwd)
      parent_directory = File.basename(File.expand_path("..", Dir.getwd))
      directory_name = working_directory == "hypernode-vagrant" ? parent_directory : working_directory
      hypernode_host = ENV['HYPERNODE_VAGRANT_NAME'] ? ENV['HYPERNODE_VAGRANT_NAME'] : directory_name
      # remove special characters so we have a valid hostname
      directory_alias = hypernode_host.gsub(/[^a-zA-Z0-9\-]/,"") + ".hypernode.local"

      # The directory and parent directory don't have to be unique names. You
      # could have this Vagrantfile in two subdirs each named 'mytestshop' and
      # the directory aliases would be double. Because there can only be one
      # Vagrantfile per directory, the path is always unique. We can create a
      # unique alias (well at least semi-unique, there might be some
      # collisions) with the hash of that path.
      require 'digest/sha1'
      hostname_hash = Digest::SHA1.hexdigest(Dir.pwd).slice(0..5) 
      directory_hash_alias = hostname_hash + ".hypernode.local"

      # set the machine hostname
      node.vm.hostname = hostname_hash + "-" + hypernode_host + "-magweb-vgr.nodes.hypernode.local"

      # Here you can define your own aliases for in the hosts file. 
      # note: if you have more than one hypernode-vagrant checkout up and
      # running, the static aliases will be defined for all of those boxes.
      # This means that hypernode.local will belong to box you booted as last.
      node.hostmanager.aliases = ["hypernode.local", "hypernode-alias", directory_alias, directory_hash_alias]
    end
  end
end
