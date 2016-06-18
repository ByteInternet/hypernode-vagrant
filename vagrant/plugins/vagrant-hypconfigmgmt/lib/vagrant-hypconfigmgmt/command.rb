# coding: utf-8
# vim: set fileencoding=utf-8

DEFAULT_MAGENTO_VERSION = 2
AVAILABLE_MAGENTO_VERSIONS = [1, 2]

DEFAULT_PHP_VERSION = 7.0
AVAILABLE_PHP_VERSIONS = [5.5, 7.0]

DEFAULT_VARNISH_STATE = false
AVAILABLE_VARNISH_STATES = [true, false]

# paths to local settings file
H_V_SETTINGS_FILE = "local.yml"

RECOMMENDED_PLUGINS = ["vagrant-hostmanager", "vagrant-vbguest"]


def retrieve_settings()
  return YAML.load_file(H_V_SETTINGS_FILE)
end


def update_settings(settings)
  File.open(H_V_SETTINGS_FILE, 'w') {|f| f.write settings.to_yaml }
end


def use_default_if_input_empty(input, default)
  if input == ''
    return default.to_s
  else
    return input
  end
end


def get_varnish_state(env)
  input = env[:ui].ask("Do you want to enable Varnish? Enter true or false [default false]: ")
  varnish_state = use_default_if_input_empty(input, DEFAULT_VARNISH_STATE)

  case varnish_state
    when "true"
      env[:ui].info("Varnish will be enabled.")
    when "false"
      env[:ui].info("Varnish will be disabled by loading a nocache vcl.")
    else
      env[:ui].error("The value #{varnish_state} is not a valid value. Please enter true or false")
      return get_varnish_state(env)
  end
  return varnish_state == "true" ? true : false
end


def get_magento_version(env)
  available_versions = AVAILABLE_MAGENTO_VERSIONS.join(' or ')
  input = env[:ui].ask("Is this a Magento #{available_versions} Hypernode? [default #{DEFAULT_MAGENTO_VERSION}]: ")
  magento_version = use_default_if_input_empty(input, DEFAULT_MAGENTO_VERSION)

  case magento_version
    when "1"
      env[:ui].info("Nginx will be configured for Magento 1. The webdir will be /data/web/public")
    when "2"
      env[:ui].info("Nginx will be configured for Magento 2. /data/web/magento2/pub will be symlinked to /data/web/public")
    else
      env[:ui].error("The value #{magento_version} is not a valid Magento version. Please enter #{available_versions}")
      return get_magento_version(env)
  end
  return magento_version.to_i
end


# todo: refactor this and the above function into one
def get_php_version(env)
  available_versions = AVAILABLE_PHP_VERSIONS.join(' or ')
  input = env[:ui].ask("Is this a PHP #{available_versions} Hypernode? [default #{DEFAULT_PHP_VERSION}]: ")
  php_version = use_default_if_input_empty(input, DEFAULT_PHP_VERSION)

  case php_version
    when "5.5"
      env[:ui].info("Will boot a box with PHP 5.5 installed")
    when "7.0"
      env[:ui].info("Will boot a box with PHP 7.0 installed")
    else
      env[:ui].error("The value #{php_version} is not a valid PHP version. Please enter #{available_versions}")
      return get_php_version(env)
  end
  return php_version.to_f
end


def ensure_varnish_state_configured(env)
  settings = retrieve_settings()
  if settings['varnish']['enabled'].nil?
    settings['varnish']['enabled'] = get_varnish_state(env)
  elsif ![true, false].include?(settings['varnish']['enabled'])
    env[:ui].error("The Varnish state configured in local.yml is invalid.")
    settings['varnish']['enabled'] = get_varnish_state(env)
  end
  update_settings(settings)
end


def ensure_magento_version_configured(env)
  settings = retrieve_settings()
  if settings['magento']['version'].nil?
    settings['magento']['version'] = get_magento_version(env)
  elsif !AVAILABLE_MAGENTO_VERSIONS.include?(settings['magento']['version'].to_i)
    env[:ui].error("The Magento version configured in local.yml is invalid.")
    settings['magento']['version'] = get_magento_version(env)
  end
  update_settings(settings)
end


# Make sure we don't link /data/web/public on Magento 2 Vagrants
# because that dir will be a symlink to /data/web/magento2/pub and 
# we mount that. On Magento 1 Vagrants we need to make sure we don't
# mount /data/web/magento2/pub.
def ensure_magento_mounts_configured(env)
  settings = retrieve_settings()
  if !settings['fs'].nil? and !settings['fs']['folders'].nil?
    if settings['fs']['disabled_folders'].nil?
	    settings['fs']['disabled_folders'] = Hash.new
    end
    if settings['magento']['version'] == 1
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
    elsif settings['magento']['version'] == 2
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


# todo: refactor this and the above function into one
def ensure_php_version_configured(env)
  settings = retrieve_settings()
  if settings['php']['version'].nil?
    settings['php']['version'] = get_php_version(env)
  elsif !AVAILABLE_PHP_VERSIONS.include?(settings['php']['version'].to_f)
    env[:ui].error("The PHP version configured in local.yml is invalid.")
    settings['php']['version'] = get_php_version(env)
  end
  update_settings(settings)
end


def ensure_setting_exists(name)
  settings = retrieve_settings()
  if settings[name].nil?
    settings[name] = Hash.new
  end
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
  

def ensure_settings_configured(env)
  old_settings = retrieve_settings()
  ensure_setting_exists('magento')
  ensure_magento_version_configured(env)
  ensure_setting_exists('php')
  ensure_php_version_configured(env)
  ensure_setting_exists('varnish')
  ensure_varnish_state_configured(env)
  ensure_magento_mounts_configured(env)
  validate_magento2_root(env)
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


module VagrantHypconfigmgmt
  class Command

    def initialize(app, env)
      @app = app
      @env = env
    end

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
  end
end
