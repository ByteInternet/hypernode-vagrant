#!/bin/sh

# die when a command has a nonzero exit code
set -e 

# make sure the required vagrant plugins are installed
vagrant plugin list | grep vagrant-vbguest || vagrant plugin install vagrant-vbguest
vagrant plugin list | grep vagrant-hostmanager || vagrant plugin install vagrant-hostmanager

# if hypernode-vagrant directory exists
if test -d hypernode-vagrant; then
    cd hypernode-vagrant
    # Destroy lingering instance if there is one
    vagrant destroy -f
    cd ../

    # Remove previous Vagrant checkout if it exists
    rm -Rf hypernode-vagrant
fi

# create a new checkout of the hypernode-vagrant repo
git clone https://github.com/ByteInternet/hypernode-vagrant

# symlink our shop into the public directory of the shared Vagrant directory
rm -Rf hypernode-vagrant/data/web/public
rm -Rf hypernode-vagrant/data/web/magento2
ln -s ../../../magento2 hypernode-vagrant/data/web/

# copy our local.yml so we can configure things like php version
cp local.yml hypernode-vagrant/local.yml

# move into the hypernode-vagrant repository directory
cd hypernode-vagrant
# make sure we have the last hypernode revision
vagrant box update || /bin/true  # don't fail if the box hasn't been added yet
# boot new vagrant instance
vagrant up

