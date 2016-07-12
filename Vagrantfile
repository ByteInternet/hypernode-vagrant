# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'
require 'fileutils'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
VAGRANT_HYPCONFIGMGMT_VERSION = "0.0.3"

# if vagrant-hypconfigmgmt is not installed, install it and abort
if !Vagrant.has_plugin?("vagrant-hypconfigmgmt", version = VAGRANT_HYPCONFIGMGMT_VERSION)
  system("vagrant plugin install vagrant-hypconfigmgmt --plugin-version #{VAGRANT_HYPCONFIGMGMT_VERSION}")
  abort "Installed the vagrant-hypconfigmgmt.\nFor the next configuration step, please again run: \"vagrant up\""
end

# path to local settings file
SETTINGS_FILE = "local.yml"
# load the settingsfile or if it does not exist yet a hash where every attribute two levels deep is nil
settings = YAML.load_file(SETTINGS_FILE) rescue Hash.new(Hash.new(nil))

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # run hypernode-vagrant configuration wizard if needed during 'vagrant up'
  config.hypconfigmgmt.enabled = true  

  config.ssh.forward_agent = true

  begin
    config.vm.box = settings['vagrant']['box'] ||= 'hypernode_php7'
    config.vm.box_url = settings['vagrant']['box_url'] ||= 'http://vagrant.hypernode.com/customer/php7/catalog.json'

    # configure all synced folder according to the filesystem type configured.
    (settings['fs']['folders'] ||= []).each do |name, folder|
      case settings['fs']['type']
        when 'nfs'
          config.vm.synced_folder folder['host'], folder['guest'], type: 'nfs', create: true
        when 'nfs_guest'
          config.vm.synced_folder folder['host'], folder['guest'], type: 'nfs_guest', create: true,
	  linux__nfs_options: %w(rw no_subtree_check all_squash insecure async),
	  map_uid: `id -u`.strip(), map_gid: `id -g`.strip(), owner: 'app', group: 'app'
        when 'rsync'
          config.vm.synced_folder folder['host'], folder['guest'], type: 'rsync', create: true, owner: "app", group: "app"
        else
          config.vm.synced_folder folder['host'], folder['guest'], type: settings['fs']['type'], create: true, owner: "app", group: "app"
      end
    end

    if settings['fs']['type'] == 'rsync'
      # Configure the window for gatling to coalesce writes.
      if Vagrant.has_plugin?("vagrant-gatling-rsync")
        config.gatling.latency = 2.5
        config.gatling.time_format = "%H:%M:%S"
        # Don't automatically sync when machines with rsync folders come up.
        # Start syncing by running 'vagrant gatling-rsync-auto'
        config.gatling.rsync_on_startup = false
      end
    end

    config.vm.provision "shell", 
    path: "vagrant/provisioning/hypernode.sh", 
    args: "-m #{settings['magento']['version']} -v #{settings['varnish']['state']} -f #{settings['firewall']['state']}"

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
          config.vm.provision "shell", 
          path: "vagrant/provisioning/fix_uid_gid_for_lxc_nfs.sh", 
          args: "-u %s -g %s" % [ `id -u`.strip(), `id -g`.strip() ]
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
        hypernode_host = hypernode_vagrant_name.gsub(/[^a-zA-Z0-9]/, "")
        hypernode_host = hypernode_host.empty? ? 'hypernode' : hypernode_host
        hypernode_host = hypernode_host.split('-')[0]

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
        node.hostmanager.aliases.concat(settings['hostmanager']['extra-aliases'] ||= [])
      end
    end
    rescue NoMethodError
      if File.exists?(SETTINGS_FILE) and !File.exists?("invalid_" + SETTINGS_FILE)
	moved_file = "invalid_%s_#{SETTINGS_FILE}" % [rand(36 ** 8).to_s(36)]
        FileUtils.mv(SETTINGS_FILE, moved_file)
        abort(<<-HEREDOC
Looks like your configuration file was corrupt or not compatible with this version of hypernode-vagrant.
No worries, we've moved it out of the way to "#{moved_file}".
Run "vagrant up" again to interactively generate a new settings file.
HEREDOC
)
    end
  end
end
