# coding: utf-8
# vim: set fileencoding=utf-8

DEFAULT_MAGENTO_VERSION = 2
AVAILABLE_MAGENTO_VERSIONS = [1, 2]

DEFAULT_PHP_VERSION = 7.0
AVAILABLE_PHP_VERSIONS = [5.5, 7.0]

DEFAULT_VARNISH_STATE = false
AVAILABLE_VARNISH_STATES = [true, false]

DEFAULT_FIREWALL_STATE = false
AVAILABLE_FIREWALL_STATES = [true, false]

DEFAULT_CGROUP_STATE = false
AVAILABLE_CGROUP_STATES = [true, false]

DEFAULT_XDEBUG_STATE = false
AVAILABLE_XDEBUG_STATES = [true, false]

DEFAULT_DOMAIN = 'hypernode.local'

# paths to local settings file
H_V_SETTINGS_FILE = "local.yml"
H_V_BASE_SETTINGS_FILE = ".local.base.yml"

RECOMMENDED_PLUGINS = ["vagrant-hostmanager", "vagrant-vbguest"]

# filesystem types that need to have the firewall disabled in the guest
# because they otherwise can cause problems
FIREWALL_INCOMPATIBLE_FS_TYPES = ['nfs_guest']

AVAILABLE_FS_TYPES = ['nfs', 'nfs_guest', 'virtualbox', 'rsync']
# This is the only one that works on all platforms.
# Perhaps we should consider using a different default on different platforms.
DEFAULT_FS_TYPE = 'virtualbox'

AVAILABLE_UBUNTU_VERSIONS = ['xenial', 'precise']
DEFAULT_UBUNTU_VERSION = 'xenial'


module VagrantHypconfigmgmt
  class Command

    def initialize(app, env)
      @app = app
      @env = env
    end


    # prompt for missing settings in local.yml. complain if there are invalid settings.
    def call(env)
      if env[:machine].config.hypconfigmgmt.enabled
        changed = ensure_settings_configured(env)
        ensure_required_plugins_are_installed(env)
        if changed
          env[:ui].info("Your hypernode-vagrant is now configured. Please run \"vagrant up\" again.")
          return
        end
      end
      @app.call(env)
    end


    def retrieve_settings()
      begin
        return YAML.load_file(H_V_SETTINGS_FILE)
      rescue Errno::ENOENT
        return YAML.load_file(H_V_BASE_SETTINGS_FILE)
      end
    end
    

    def update_settings(settings)
      File.open(H_V_SETTINGS_FILE, 'w') {|f| f.write settings.to_yaml }
    end
    
    
    def use_default_if_input_empty(input, default)
      return input == '' ? default.to_s : input
    end
    
    
    def get_setting(env, available, default, ask_message)
      input = env[:ui].ask(ask_message)
      value = use_default_if_input_empty(input, default)
      unless available.map { | v | v.to_s }.include?(value.to_s)
        available_versions = get_options_string(available)
        env[:ui].error("The value #{value} is not a valid value. Please enter #{available_versions}")
        return get_setting(env, available, default, ask_message)
      end
      return value
    end 


    def get_options_string(available)
      return available.map { | v | v.to_s }.join(' or ')
    end


    def get_php_version(env)
      available_versions = get_options_string(AVAILABLE_PHP_VERSIONS)
      ask_message = "Is this a PHP #{available_versions} Hypernode? [default #{DEFAULT_PHP_VERSION}]: "
      php_version = get_setting(env, AVAILABLE_PHP_VERSIONS, DEFAULT_PHP_VERSION, ask_message).to_f
      env[:ui].info("Will boot a box with PHP #{php_version} installed")
      return php_version
    end


    def get_magento_version(env)
      available_versions = get_options_string(AVAILABLE_MAGENTO_VERSIONS)
      ask_message = "Is this a Magento #{available_versions} Hypernode? [default #{DEFAULT_MAGENTO_VERSION}]: "
      magento_version = get_setting(env, AVAILABLE_MAGENTO_VERSIONS, DEFAULT_MAGENTO_VERSION, ask_message).to_i
      message = "Nginx will be configured for Magento #{magento_version}."
      case magento_version
        when 1
          message += " The webdir will be /data/web/public"
        when 2
          message += " /data/web/magento2/pub will be symlinked to /data/web/public"
      end
      env[:ui].info(message)
      return magento_version
    end


    def get_varnish_state(env)
      ask_message = "Do you want to enable Varnish? Enter true or false [default false]: "
      varnish_enabled = get_setting(env, AVAILABLE_VARNISH_STATES, DEFAULT_VARNISH_STATE, ask_message)
      varnish_state = varnish_enabled == 'true' ? true : false
      message = "Varnish will be #{varnish_state ? 'enabled' : 'disabled'}"
      if ! varnish_state
        message += " by loading a nocache vcl."
      end
      env[:ui].info(message)
      return varnish_state
    end


    def get_firewall_state(env)
      ask_message = "Do you want to enable the production-like firewall? Enter true or false [default false]: "
      firewall_enabled = get_setting(env, AVAILABLE_FIREWALL_STATES, DEFAULT_FIREWALL_STATE, ask_message)
      firewall_state = firewall_enabled == 'true' ? true : false
      message = "The firewall will be #{firewall_state ? 'enabled' : 'disabled'}"
      env[:ui].info(message)
      return firewall_state
    end


    def get_cgroup_state(env)
      ask_message = "Do you want to enable production-like memory management? \n"
      ask_message << "This might be slower but it is more in-line with a real Hypernode. \n"
      ask_message << "Note: for LXC boxes this setting is disabled. \n"
      ask_message << "Enter true or false [default false]: "
      cgroup_enabled = get_setting(env, AVAILABLE_CGROUP_STATES, DEFAULT_CGROUP_STATE, ask_message)
      cgroup_state = cgroup_enabled == 'true' ? true : false
      message = "Production-like memory management will be #{cgroup_state ? 'enabled' : 'disabled'}"
      env[:ui].info(message)
      return cgroup_state
    end


    def get_xdebug_state(env)
      ask_message = "Do you want to install Xdebug? Enter true or false [default false]: "
      xdebug_enabled = get_setting(env, AVAILABLE_XDEBUG_STATES, DEFAULT_XDEBUG_STATE, ask_message)
      xdebug_state = xdebug_enabled == 'true' ? true : false
      message = "Xdebug will be #{xdebug_state ? 'enabled' : 'disabled'}"
      env[:ui].info(message)
      return xdebug_state
    end


    def get_fs_type(env)
      ask_message = "What filesystem type do you want to use? Options: nfs_guest, nfs, rsync, virtualbox [default #{DEFAULT_FS_TYPE}]: "
      fs_type = get_setting(env, AVAILABLE_FS_TYPES, DEFAULT_FS_TYPE, ask_message)
      case fs_type
        when "nfs"
          message = ("The guest will mount NFS folders served by the host.")
        when "nfs_guest"
          message = ("The host will mount NFS folders served by the guest")
        when "virtualbox"
          message = ("Virtualbox is the default fs type. If you later want to try a faster fs type like nfs_guest, edit local.yml")
        when "rsync"
          message = ("Will use rsync to sync the folders. Don't forget to start the filesync with 'vagrant rsync-auto' or 'vagrant gatling-rsync-auto'!")
        else
          message = ("Unknown filesystem type. If it's valid for Vagrant then there is no problem. Otherwise you can edit local.yml to change it.")
      end 
      env[:ui].info(message)
      return fs_type
    end


    def get_ubuntu_version(env)
      ask_message = "What Ubuntu version do you want to use? Options: xenial, precise (deprecated) [default #{DEFAULT_UBUNTU_VERSION}]: "
      ubuntu_version = get_setting(env, AVAILABLE_UBUNTU_VERSIONS, DEFAULT_UBUNTU_VERSION, ask_message)
      case ubuntu_version
        when "xenial"
          message = ("Will use the Xenial version. This is the default.")
        when "precise"
          message = ("Will use the Precise version (will soon be deprecated)")
      end 
      env[:ui].info(message)
      return ubuntu_version
    end


    # Make sure we don't link /data/web/public on Magento 2 Vagrants
    # because that dir will be a symlink to /data/web/magento2/pub and 
    # we mount that. On Magento 1 Vagrants we need to make sure we don't
    # mount /data/web/magento2/pub.
    def ensure_magento_mounts_configured(env)
      settings = retrieve_settings()
      if !settings['fs'].nil? and !settings['fs']['folders'].nil?
        settings['fs']['disabled_folders'] ||= Hash.new
        if settings['magento']['version'].to_s == "1"
          if !settings['fs']['disabled_folders']['magento1'].nil?
            settings['fs']['folders']['magento1'] = settings['fs']['disabled_folders']['magento1'].clone
            settings['fs']['disabled_folders'].delete('magento1')
            env[:ui].info("Re-enabling fs->disabled_folders->magento1 in the local.yml.")
          end
          if !settings['fs']['folders']['magento2'].nil?
            settings['fs']['disabled_folders']['magento2'] = settings['fs']['folders']['magento2'].clone
            settings['fs']['folders'].delete('magento2')
            env[:ui].info("Disabling fs->folders->magento2 in the local.yml because Magento 1 was configured.")
          end
        elsif settings['magento']['version'].to_s == "2"
          if !settings['fs']['disabled_folders']['magento2'].nil?
            settings['fs']['folders']['magento2'] = settings['fs']['disabled_folders']['magento2'].clone
            settings['fs']['disabled_folders'].delete('magento2')
            env[:ui].info("Re-enabling fs->disabled_folders->magento2 in the local.yml.")
          end
          if !settings['fs']['folders']['magento1'].nil?
            settings['fs']['disabled_folders']['magento1'] = settings['fs']['folders']['magento1'].clone
            settings['fs']['folders'].delete('magento1')
            env[:ui].info("Disabling fs->folders->magento1 in the local.yml because Magento 2 was configured..")
          end
        end 
        if settings['fs']['disabled_folders'] == Hash.new
          settings['fs'].delete('disabled_folders')
        end
      end
      update_settings(settings)
    end


    def ensure_attribute_configured(env, name, attribute, available)
      settings = retrieve_settings()
      if settings[name][attribute].nil?
        settings[name][attribute] = yield
      elsif !available.map { | v | v.to_s }.include?(settings[name][attribute].to_s)
        env[:ui].error("The #{name} #{attribute} configured in local.yml is invalid.")
        settings[name][attribute] = yield
      end
      update_settings(settings)
    end


    def ensure_setting_exists(name)
      settings = retrieve_settings()
      settings[name] ||= Hash.new
      update_settings(settings) 
    end
    
    
    def validate_magento2_root(env)
      settings = retrieve_settings()
      if !settings['fs'].nil? and !settings['fs']['folders'].nil?
        if settings['fs']['folders'].select{ |_, f| f['guest'].start_with?('/data/web/public') }.any? && settings['magento']['version'] == 2
          env[:ui].info("Can not configure a synced /data/web/public directory with Magento 2, this will be symlinked to /data/web/magento2!")
          env[:ui].error("Please remove all fs->folders->*->guest paths that start with /data/web/public from your local.yml. Use /data/web/magento2 instead.")
        end
      end
    end


    def inform_if_gatling_not_installed(env)
      settings = retrieve_settings()
      if settings['fs']['type'] == 'rsync' and !Vagrant.has_plugin?('vagrant-gatling-rsync')
        env[:ui].info(<<-HEREDOC
'Tip: run "vagrant plugin install vagrant-gatling-rsync" to speed up 
shared folder operations.\nYou can then sync with "vagrant gatling-rsync-auto"
instead of "vagrant rsync-auto" to increase performance
HEREDOC
)
      end
    end

    def ensure_vagrant_box_type_configured(env)
      settings = retrieve_settings()
      settings['ubuntu_version'] ||= get_ubuntu_version(env)
      if settings['ubuntu_version'] == 'xenial'
        settings['vagrant']['box'] = 'hypernode_xenial'
        settings['vagrant']['box_url'] = 'http://vagrant.hypernode.com/customer/xenial/catalog.json'
      else
        case settings['php']['version']
          when 5.5
            env[:ui].info("Will use PHP 5.5. If you want PHP 7 instead change the php version in local.yml.")
            settings['vagrant']['box'] = 'hypernode_php5'
            settings['vagrant']['box_url'] = 'http://vagrant.hypernode.com/customer/php5/catalog.json'
          when 7.0
            env[:ui].info("Will use PHP 7. If you want PHP 5.5 instead change the php version in local.yml.")
            settings['vagrant']['box'] = 'hypernode_php7'
            settings['vagrant']['box_url'] = 'http://vagrant.hypernode.com/customer/php7/catalog.json'
        end
      end
      update_settings(settings)
    end

    def ensure_default_domain_configured(env)
      settings = retrieve_settings()
      settings['hostmanager']['default_domain'] ||= DEFAULT_DOMAIN
      update_settings(settings)
    end

      
    def ensure_firewall_disabled_for_incompatible_fs_types(env)
      settings = retrieve_settings()
      if FIREWALL_INCOMPATIBLE_FS_TYPES.include?(settings['fs']['type'])
        env[:ui].info("Disabling the firewall in the guest because fs type #{settings['fs']['type']} might run into some problems otherwise.")
        settings['firewall']['state'] = false
      end
      update_settings(settings)
    end

    
    def ensure_fs_type_configured(env)
      settings = retrieve_settings()
      settings['fs']['type'] ||= get_fs_type(env)
      update_settings(settings)
    end
    

    def configure_magento(env)
      ensure_setting_exists('magento')
      ensure_attribute_configured(
        env, 'magento', 'version', 
        AVAILABLE_MAGENTO_VERSIONS
      ) { get_magento_version(env) }
    end
    
    
    def configure_php(env)
      ensure_setting_exists('php')
      ensure_attribute_configured(
        env, 'php', 'version',
        AVAILABLE_PHP_VERSIONS
      ) { get_php_version(env) }
    end
    
    
    def configure_varnish(env)
      ensure_setting_exists('varnish')
      ensure_attribute_configured(
        env, 'varnish', 'state',
        AVAILABLE_VARNISH_STATES
      ) { get_varnish_state(env) }
    end


    def configure_firewall(env)
      ensure_setting_exists('firewall')
      ensure_firewall_disabled_for_incompatible_fs_types(env)
      ensure_attribute_configured(
        env, 'firewall', 'state',
        AVAILABLE_FIREWALL_STATES
      ) { get_firewall_state(env) }
    end


    def configure_cgroup(env)
      ensure_setting_exists('cgroup')
      ensure_attribute_configured(
        env, 'cgroup', 'state',
        AVAILABLE_CGROUP_STATES
      ) { get_cgroup_state(env) }
    end


    def configure_xdebug(env)
      ensure_setting_exists('xdebug')
      ensure_attribute_configured(
        env, 'xdebug', 'state',
        AVAILABLE_XDEBUG_STATES
      ) { get_xdebug_state(env) }
    end


    def configure_synced_folders(env)
      ensure_setting_exists('fs')
      ensure_fs_type_configured(env)
      ensure_magento_mounts_configured(env)
      validate_magento2_root(env)
      inform_if_gatling_not_installed(env)
    end


    def configure_vagrant(env)
      ensure_setting_exists('vagrant')
      ensure_vagrant_box_type_configured(env)
    end


    def configure_hostmanager(env)
      ensure_setting_exists('hostmanager')
      ensure_default_domain_configured(env)
    end
    
    
    def ensure_settings_configured(env)
      old_settings = retrieve_settings()
      configure_magento(env)
      configure_php(env)
      configure_varnish(env)
      configure_synced_folders(env)
      configure_firewall(env)
      configure_cgroup(env)
      configure_xdebug(env)
      configure_vagrant(env)
      configure_hostmanager(env)
      new_settings = retrieve_settings()
      return new_settings.to_yaml != old_settings.to_yaml
    end
    
    
    def ensure_required_plugins_are_installed(env)
      RECOMMENDED_PLUGINS.each do |plugin|
        unless Vagrant.has_plugin?(plugin)
          env[:ui].info("Installing the #{plugin} plugin.")
          system("vagrant plugin install #{plugin}")
        end
      end
    end
  end
end
