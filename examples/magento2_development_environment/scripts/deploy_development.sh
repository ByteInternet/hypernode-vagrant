#!/bin/sh

# die when a command has a nonzero exit code
set -e 

# get running vagrant ip
BOX_IP=$(cd hypernode-vagrant; vagrant ssh -- ip route | awk 'END{print $NF}')
echo "Registered ip: $BOX_IP"

# don't check ssh host key of vagrant box
export ANSIBLE_HOST_KEY_CHECKING=False

# deploy current revision to vagrant
ansible-playbook provisioning/deploy_magento2_to_vagrant.yml --extra-vars "@vars_development.yml" --user=app -i "$BOX_IP," -v # mind the trailing comma
