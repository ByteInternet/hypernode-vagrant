Magento 2 example
============================
Example project that allows you to set up a Magento 2 environment in a `hypernode-vagrant` by just running one command.

Can be used for setting up a development environment or automated testing with a fresh install.

## Usage

Make sure you have Vagrant installed and either Virtualbox or LXC.  
Configure the local.yml accordingly if you use LXC, the default is Virtualbox.

Requirements: Make, Ansible

```
apt-get install make ansible
```

The scripts expect a couple of things in your environment
```
export MAGENTO_MARKETPLACE_PUBLIC_KEY=<YOUR MARKETPLACE ID>
export MAGENTO_MARKETPLACE_PRIVATE_KEY=<YOUR SECRET KEY>
export MAGENTO_ADMIN_PASSWORD=admin1234>  # requires digits in the password
```

To get your keys, login at your [My Magento account](https://www.magentocommerce.com/products/customer/account/login). 

```
Go Connect => Developer => Secure keys.
```

### Setting up a Magento 2 development environment
Run the following command to:

- check out the latest `hypernode-vagrant` revision
- ensure an instance is running
- deploy Magento 2 in the virtual machine

```
make devenv
```

After making changes in the magento2 directory that will now have been
created in the same directory as the Makefile you can re-deploy to the
existing Vagrant environment with the following command:

```
make update
```

### Cleaning it all up
To destroy the Vagrant box and remove all the generated content:

```
make clean
```

