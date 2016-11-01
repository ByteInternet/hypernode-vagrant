#!/bin/bash

# die when a command has a nonzero exit code
set -e 

while getopts "k:" opt; do
    case "$opt" in
        k)
            keep_node="$OPTARG" ;;
    esac
done

function runtests {
    if type nosetests > /dev/null 2>&1; then
        nosetests testcase.py
    else
        echo "Install python-nosetests to run the testcase, skipping for now.."
    fi
}

running=$([ -d hypernode-vagrant ] && cd hypernode-vagrant && vagrant status | grep running > /dev/null 2>&1 && echo 1 || echo 0)

if [ -z "$keep_node" -o "$running" -eq 0 ]; then
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
    git clone https://github.com/byteinternet/hypernode-vagrant
    
    # move into the hypernode-vagrant repository directory
    cd hypernode-vagrant
    
    # write our local.yml to the hypernode-vagrant directory
    cat << EOF > local.yml
---
fs:
  type: virtualbox
hostmanager:
  extra-aliases:
  - my-custom-store-url1.local
  - my-custom-store-url2.local
magento:
  version: 1
php:
  version: 5.5
varnish:
  state: false
firewall:
  state: true
cgroup:
  state: true
vagrant:
  box: hypernode_php5
  box_url: http://vagrant.hypernode.com/customer/php5/catalog.json
EOF
    
    # make sure we have the last hypernode revision
    vagrant box update || /bin/true  # don't fail if the box hasn't been added yet
    # boot new vagrant instance
    vagrant up
    cd ../
fi;

# register unique hostname of booted instance
cd hypernode-vagrant
BOX_IP=$(vagrant ssh-config | grep HostName | awk '{print$NF}')
echo "Registered ip: $BOX_IP"
(cd ../ ; git checkout vars_test.yml)
echo "ansible_ssh_port: $(vagrant ssh-config | grep Port | awk '{print $NF}')" >> ../vars_test.yml
cd ../

# don't check ssh host key of vagrant box
export ANSIBLE_HOST_KEY_CHECKING=False

# apply deployment playbook
ansible-playbook provisioning/magento1.yml --extra-vars "@vars_test.yml" --user=app -i "$BOX_IP," -v # mind the trailing comma

# test if new node was successfully provisioned
runtests

# run the provisioning scripts again to ensure idempotency
ansible-playbook provisioning/magento1.yml --extra-vars "@vars_test.yml" --user=app -i "$BOX_IP," # mind the trailing comma

# test if new node is still ok after second run
runtests


if ! $keep_node; then
	cd hypernode-vagrant
	# Destroy test instance
	vagrant destroy -f
	cd ../
fi;
