# Hypernode test environment for MacOSX and Linux

You can start developing on your own local Hypernode within 15 minutes.

## Starting the test environment

1. Install [Virtualbox 4.3.18 or later](https://www.virtualbox.org/wiki/Downloads).
2. Install [Vagrant 1.6.4 or later](http://www.vagrantup.com/downloads.html).
3. Clone this [repository](https://github.com/ByteInternet/hypernode-vagrant.git) using Git or download the [zip file](https://github.com/ByteInternet/hypernode-vagrant/archive/master.zip) from Github.

```
# check if version > 1.6.4 ?
vagrant --version 
cd hypernode-vagrant
vagrant plugin install vagrant-vbguest vagrant-hostmanager
vagrant up
```

Voila! Access your local Hypernode through [http://hypernode.local/](http://hypernode.local/) or [http://localhost:8080/](http://localhost:8080/).

## Using the test environment

### Uploading files

The local directories `data/web/public/` and `data/web/nginx/` are bound to the Vagrant image. You can use this local dir to edit all your files.

So fire up PHPStorm and edit away locally. Then check out the Hypernode box to see results.

### SSH

SSH is available at hostname hypernode.local, port 22 or at hostname localhost, port 2222.

```bash
ssh app@hypernode.local
```

You can use this config snippet for SSH to ease logging in and then just `ssh hypernode.local`:

```
Host hypernode.local
    Hostname 127.0.0.1
    User app
    StrictHostKeyChecking no  # because the host key will change over time
```

### MySQL

MySQL is available at hostname hypernode.local, port 3306 or at hostname localhost, port 3307.

```bash
# find you MySQL password in /data/web/.my.cnf by loging in to SSH
# ssh app@hypernode.local cat /data/web/.my.cnf

mysql -u app --host=hypernode.local -p
```

To connect directly from the vagrant directory you can use `vagrant ssh`. This will log you in as the `vagrant` user.
This will allow you to use `sudo` and manage the server. Do not use this for normal operation, however, the app user should be used for normal usage and as the website user.

## Keeping up to date with Hypernode versions

With every Hypernode release, we'll update the Hypernode vagrant image as well. Use the following to update your box (you'll lose your MySQL data unless you make a mysqldump first!):

```bash
vagrant box update
# optionally backup MySQL, whose data is not currently in a shared directory
vagrant destroy
vagrant up
```

## Customizing the setup

You might have some ports already in use. Hypernode by default forwards ports 2222 to 22, 3307 to 3306 and 8080 to 80.

If you want to change these ports, just have a look at the Vagrant file. It is pretty self-explanatory.

## Troubleshooting

### ==> default: stdin: is not a tty

This is Vagrant bug [#1673](https://github.com/mitchellh/vagrant/issues/1673) and perfectly harmless.
