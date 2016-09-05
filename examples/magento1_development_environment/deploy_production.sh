#!/bin/bash

PRODUCTION_HOSTNAME='example.hypernode.io'

# die when a command has a nonzero exit code
set -e 

function runtests {
    if type nosetests > /dev/null 2>&1; then
        TEST_URL=$PRODUCTION_HOSTNAME nosetests testcase.py
    else
        echo "Install python-nosetests to run the testcase, skipping for now.."
    fi
}


# apply deployment playbook with production settings
ansible-playbook provisioning/magento1.yml --extra-vars "@vars_prod.yml" --user=app -i "$PRODUCTION_HOSTNAME," -v # mind the trailing comma

# test if the production Hypernode was succesfully provisioned
runtests
