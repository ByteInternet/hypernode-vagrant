# Hypernode test environment

## Requirements

1. Install Virtualbox 4.3.18 or later.
2. Install Vagrant 1.6.4 or later.
3. Clone this [repository](https://github.com/ByteInternet/hypernode-vagrant.git) using Git or download the [tarball](https://github.com/ByteInternet/hypernode-vagrant/archive/master.zip) from Github.


## Starting the test environment

```
cd hypernode-vagrant
vagrant plugin install vagrant-vbguest
vagrant up
```

You might see an error: `==> default: stdin: is not a tty`. This is Vagrant bug [#1673](https://github.com/mitchellh/vagrant/issues/1673) and perfectly harmless. 

## Using the test environment

1. Your Magento is available at [http://127.0.0.1:8080](http://127.0.0.1:8080).
2. MySQL is available at 127.0.0.1:3307.
3. PHPMyAdmin is available at [http://127.0.0.1:8080/phpmyadmin/](http://127.0.0.1:8080/phpmyadmin/).
4. SSH is available on 127.0.0.1:2222.

You can use `ssh -p 2222 app@localhost` to connect to SSH. You can also use this config snippet for SSH:

```
Host hn-vagrant
    Hostname 127.0.0.1
    User app
    Port 2222
    StrictHostKeyChecking no  # because the host key will change over time
````
