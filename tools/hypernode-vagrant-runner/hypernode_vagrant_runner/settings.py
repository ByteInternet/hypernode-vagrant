HYPERNODE_VAGRANT_REPOSITORY = 'https://github.com/byteinternet/hypernode-vagrant'
REQUIRED_VAGRANT_PLUGINS = [
    'vagrant-vbguest',
    'vagrant-hypconfigmgmt'
]
HYPERNODE_VAGRANT_PHP_VERSIONS = [
    '5.5',
    '7.0'
]
HYPERNODE_VAGRANT_BOX_NAMES = {
    '5.5': 'hypernode_php5',
    '7.0': 'hypernode_php7',
}
HYPERNODE_VAGRANT_BOX_URLS = {
    '5.5': 'http://vagrant.hypernode.com/customer/php5/catalog.json',
    '7.0': 'http://vagrant.hypernode.com/customer/php7/catalog.json',
}
HYPERNODE_XENIAL_BOX_NAME = 'hypernode'
HYPERNODE_XENIAL_URL = 'http://vagrant.hypernode.com/customer/xenial/catalog.json'

# Run the commands as 'app' by default. This is the user that is
# available on production Hypernodes.
HYPERNODE_VAGRANT_DEFAULT_USER = 'app'
HYPERNODE_VAGRANT_USERS = [
    'app',
    'root',
    'vagrant'
]

# Use the last available PHP version as the default
HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION = HYPERNODE_VAGRANT_PHP_VERSIONS[-1]

HYPERNODE_VAGRANT_CONFIGURATION = """
---
fs:
  type: rsync
hostmanager:
  extra-aliases: []
  default_domain: hypernode.local
magento:
  version: 1
php:
  version: {php_version}
varnish:
  state: false
firewall:
  state: true
cgroup:
  state: true
xdebug:
  state: {xdebug_enabled}
vagrant:
  box: {box_name}
  box_url: {box_url}
ubuntu_version: {ubuntu_version}
"""

# The path in the vagrant where the project will be uploaded to
UPLOAD_PATH = '/data/web/public'  # The webroot
