# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'
require 'fileutils'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# paths to local settings file
SETTINGS_FILE = "local.yml"
SETTINGS_EXAMPLES_FILE = "local.example.yml"

# source local config
unless File.exist?(SETTINGS_FILE)
  FileUtils.cp(SETTINGS_EXAMPLES_FILE, SETTINGS_FILE)
end
settings = YAML.load_file SETTINGS_FILE

if settings['php'].nil? or settings['php']['version'].nil?
  settings_php_version = 5.5
else
  settings_php_version = settings['php']['version']
end
php_version = ENV['HYPERNODE_VAGRANT_PHP_VERSION'] ? ENV['HYPERNODE_VAGRANT_PHP_VERSION'] : settings_php_version

available_php_versions = [5.5, 7.0]
unless available_php_versions.include?(php_version)
  abort "Configure an available php version in local.yml: #{available_php_versions.join(', ')}. You specified: #{php_version}"
end

if !Vagrant.has_plugin?("vagrant-gatling-rsync") and settings['fs']['type'] == 'rsync'
  puts "Tip: run 'vagrant plugin install vagrant-gatling-rsync' to speed up \
shared folder operations.\nYou can then sync with 'vagrant gatling-rsync-auto' \
instead of 'vagrant rsync-auto' to increase performance"
end

# abort if vagrant-hostmanager is not installed
if !Vagrant.has_plugin?("vagrant-hostmanager")
  abort "Please install the 'vagrant-hostmanager' module"
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.forward_agent = true

  if php_version == 7.0
    config.vm.box = 'hypernode_php7'
    config.vm.box_url = 'http://vagrant.hypernode.com/customer/php7/catalog.json'
  else
    config.vm.box = 'hypernode_php5'
    config.vm.box_url = 'http://vagrant.hypernode.com/customer/php5/catalog.json'
  end

  if !settings['fs']['folders'].nil?
    settings['fs']['folders'].each do |name, folder|
      if settings['fs']['type'] == 'nfs'
          config.vm.synced_folder folder['host'], folder['guest'], type: settings['fs']['type'], create: true
      elsif settings['fs']['type'] == 'rsync'
          config.vm.synced_folder folder['host'], folder['guest'], type: 'rsync', create: true, owner: "app", group: "app"
	  # Configure the window for gatling to coalesce writes.
	  if Vagrant.has_plugin?("vagrant-gatling-rsync")
	    config.gatling.latency = 2.5
	    config.gatling.time_format = "%H:%M:%S"
	    # Don't automatically sync when machines with rsync folders come up.
	    # Start syncing by running 'vagrant gatling-rsync-auto'
	    config.gatling.rsync_on_startup = false
	  end
      else
          config.vm.synced_folder folder['host'], folder['guest'], type: settings['fs']['type'], create: true, owner: "app", group: "app"
      end
    end
  end

  config.vm.provision "shell", path: "vagrant/provisioning/hypernode.sh"

  config.vm.provider :virtualbox do |vbox, override|
    override.vm.network "private_network", type: "dhcp"
    override.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
    override.vm.network "forwarded_port", guest: 3306, host: 3307, auto_correct: true
    vbox.memory = 2048
    vbox.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
  end

  config.vm.provider :lxc do |lxc, override|
      if settings['fs']['type'] == 'nfs'
        # in case of lxc and nfs make sure the app user has the same uid and gid as the host
        uid = `id -u`.strip()
        gid = `id -g`.strip()
        config.vm.provision "shell", path: "vagrant/provisioning/fix_uid_gid_for_lxc_nfs.sh", args: "-u #{uid} -g #{gid}"
      end
    lxc.customize 'cgroup.memory.limit_in_bytes', '2048M'
  end

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
        vm.communicate.execute("ifconfig `find /sys/class/net -name 'eth*' -printf '%f\n' | tail -n 1`") do |type, data|
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
      hypernode_vagrant_name = ENV['HYPERNODE_VAGRANT_NAME'] ? ENV['HYPERNODE_VAGRANT_NAME'] : directory_name

      # remove special characters so we have a valid hostname
      hypernode_host = hypernode_vagrant_name.gsub(/[^a-zA-Z0-9\-]/, "") 
      hypernode_host = hypernode_host.empty? ? 'hypernode' : hypernode_host

      directory_alias = hypernode_host + ".hypernode.local"

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

      # Add user defined (local.yml) aliases to the hosts file.
      if !settings['hostmanager'].nil? and !settings['hostmanager']['extra-aliases'].nil?
        node.hostmanager.aliases += settings['hostmanager']['extra-aliases']
      end
    end
  end
end
