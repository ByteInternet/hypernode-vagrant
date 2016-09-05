Magento 1 example
=================

Example project that with one command installs Magento 1 in the `hypernode-vagrant` and runs a test on the front-end. 

For this example, make sure you have the following installed:
- ansible 

And optionally if you want to run the front-end tests as well:
- python-nose (or install nose in a virtualenv)
- python-selenium (or install selenium in a virtualenv)
- <a href=”https://gist.github.com/julionc/7476620”>PhantomJS</a>

# Setting up a Magento development environment

Run:
```
./deploy_test.sh -k true
```

This does the following things:

- creates a new hypernode-vagrant checkout if it does not exist
- starts a new instance if none is running
- if there is an instance but it is shut down (halted), it will be destroyed
- deploys the provisioning/magento1.yml playbook
- runs the testcase if nosetests is installed
- deploys the provisioning/magento1.yml playbook again to ensure idempotency
- runs the testcase again if nosetests is installed

If you do not want to keep the same instance between runs, run the command without `-k true`

```
./deploy_test.sh 
```

This will create a new `hypernode-vagrant` checkout and instance every time.


Finally if you want to deploy your project to a real hypernode, simply run:
```
./deploy_production.sh
```

This will run the playbook and tests on the production Hypernode specified
in the `PRODUCTION_HOSTNAME` in `deploy_production.sh`. 
Note: `vars_prod.yml` will be used instead of `vars_test.yml`
