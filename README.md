# Hypernode test environment for MacOSX and Linux

You can start developing on your own local Hypernode within 15 minutes.

## Starting the test environment

### Installing

1. Install [Virtualbox 4.3.18 or later](https://www.virtualbox.org/wiki/Downloads), or [LXC](https://help.ubuntu.com/lts/serverguide/lxc.html) (experimental).
2. Install [Vagrant 1.6.4 or later](http://www.vagrantup.com/downloads.html).
3. Clone this [repository](https://github.com/ByteInternet/hypernode-vagrant.git) using Git or download the [zip file](https://github.com/ByteInternet/hypernode-vagrant/archive/master.zip) from Github.

```
    # check if vagrant version > 1.6.4 ?
    vagrant --version
    cd hypernode-vagrant
    vagrant plugin install vagrant-hostmanager
```

```
    vagrant plugin install vagrant-vbguest
    vagrant up --provider virtualbox
```

### Configuring your hypernode vagrant

The first time you run `vagrant up` after downloading the hypernode-vagrant zip file or cloning this git repository, some user input is required to prepare and setup some configuration:

```
    $ vagrant up

    Bringing machine 'hypernode' up with 'virtualbox' provider...
        hypernode: Is this a Magento 1 or 2 Hypernode? [default 2]: 1
    ==> hypernode: Nginx will be configured for Magento 1. The webdir will be /data/web/public
        hypernode: Is this a PHP 5.5 or 7.0 Hypernode? [default 7.0]: 5.5
    ==> hypernode: Will boot a box with PHP 5.5 installed
        hypernode: Do you want to enable Varnish? Enter true or false [default false]:
    ==> hypernode: Varnish will be disabled by loading a nocache vcl.
        hypernode: What filesystem type do you want to use? Options: nfs_guest, nfs, rsync, virtualbox [default virtualbox]:
    ==> hypernode: Virtualbox is the default fs type. If you later want to try a faster fs type like nfs_guest, edit local.yml
    ==> hypernode: Disabling fs->folders->magento2 in the local.yml because Magento 1 was configured.
        hypernode: Do you want to enable the production-like firewall? Enter true or false [default false]:
    ==> hypernode: The firewall will be disabled
    ==> hypernode: Will use PHP 5.5. If you want PHP 7 instead change the php version in local.yml.
    ==> hypernode: Your hypernode-vagrant is now configured. Please run "vagrant up" again.
```

By answering the questions, you can decide whether:
- A magento2 or a magento1 environment will be setup depending on what mag version you choose to use.
- The desirable php version will be used
- Varnish should be enabled or not
- A firewall configuration similar to production will be used

This way a valid local.yml is created which is then used to preconfigure the hypernode-vagrant.
When this is done, you can run `vagrant up` again to start your vagrant box.

Voila! Access your local Hypernode through [http://hypernode.local/](http://hypernode.local/) or [http://localhost:8080/](http://localhost:8080/).

### Using vagrant with LXC (Linux only)

Virtualbox can be rather slow. In case you are on Linux you can also use LXC instead.

To do this, change the synced folder type in local.yml to something other than virtualbox like rsync or nfs:
```
    fs:
      type: rsync
```

Then install the vagrant-lxc plugin:
```
    vagrant plugin install vagrant-lxc
    vagrant up --provider lxc
```


## Using the test environment

### Uploading files

The local directories `data/web/public/` and `data/web/nginx/` are bound to the Vagrant image. You can use this local dir to edit all your files.

So fire up PHPStorm and edit away locally. Then check out the Hypernode box to see results.

### SSH

SSH is available at port 22 on hostname hypernode.local, or at port 2222 localhost.

```
    ssh app@hypernode.local
```

You can use this config snippet for SSH to ease logging in and then just `ssh hypernode.local`:

```
    Host hypernode.local
        Hostname hypernode.local
        User app
        StrictHostKeyChecking no
        # because the host key will change over time
```

### PHP version

The default php version is 5.5. To boot a hypernode-vagrant box with php 7.0 edit the local.yml file or input 5.5 or 7.0 for when asked for the required php version when setting up your vagrant.

Change local.yml to:
```
    php:
      version: 7.0
```

Destroy and re-create the box
```
    vagrant destroy -f
    vagrant up
```


### MySQL

MySQL is available at hostname hypernode.local, port 3306 or at localhost, port 3307.

```
     # find you MySQL password in /data/web/.my.cnf by loging in to SSH
     # ssh app@hypernode.local cat /data/web/.my.cnf

     mysql -u app --host=hypernode.local -p
```

To connect directly from the vagrant directory you can use `vagrant ssh`. This will log you in as the `vagrant` user.
This will allow you to use `sudo` and manage the server. Do not use this for normal operation, however, the app user should be used for normal usage and as the website user.

### Mail

All mail is redirected to a local [MailHog](https://github.com/mailhog/MailHog) instance. Access MailHog at http://b033d.hypernode.local:8025 \(replace name with your instance's hostname\).

![Mail is routed to MailHog](https://raw.githubusercontent.com/ByteInternet/hypernode-vagrant/12f11242e4ed66631ee2dc4e44390b3f62c27932/Documentation/mailhog.png "MailHog impression")


## Keeping up to date with Hypernode versions

With every Hypernode release, we'll update the Hypernode vagrant image as well. Use the following to update your box (you'll lose your MySQL data unless you make a mysqldump first!):

```
    vagrant box update
    # optionally backup MySQL, whose data is not currently in a shared directory
    vagrant destroy
    vagrant up
```


## Customizing the setup

You might have some ports already in use. Hypernode by default forwards ports 2222 to 22, 3307 to 3306 and 8080 to 80.

Collisions will be automatically resolved, Vagrant will print the newly assigned ports if that happens.

If you want to change these ports, just have a look at the Vagrant file. It is pretty self-explanatory.

## Running multiple hypernode-vagrant boxes at the same time
If you have two checkouts of this repository or have copied this Vagrantfile to multiple projects, you can run them simultaneously.
Some things to keep in mind:

1. The static aliases (hypernode.local, hypernode-alias) will point to the box that was booted last.

2. Aliases are created based on the name of the directory the Vagrantfile is in. If the dir name is 'hypernode-vagrant' the parent directory name will be used. You can override this name with an environment variable
    ```
    HYPERNODE_VAGRANT_NAME="mywebshop" vagrant up
    ```

    You can access the node on
    ```
    http://mywebshop.hypernode.local
    ```

3. You can add your own aliases by updating the following section in the local.yml file
    ```
    hostmanager:
      extra-aliases:
        - my-custom-store-url1.local
        - my-custom-store-url2.local
    ```

    Apply these settings to a provisioned environment by running the following command inside your Vagrant directory
    ```
    vagrant hostmanager
    ```

4. If there are two hypernode-vagrants running with the same name, you can still access them both using the alias derived from the path name. The hash based on the Vagrantfile's directory path is always unique because there can only be one Vagrantfile per directory.
    ```
    http://b033d-mywebshop-magweb-vgr.nodes.hypernode.local
    http://eb7b8-mywebshop-magweb-vgr.nodes.hypernode.local
    ```

For the defined aliases check ```/etc/hosts``` on Unix based systems (Linux, Mac).
On Windows see ```C:\Windows\System32\drivers\etc\hosts```.


## Working with shared folders

When you start the vagrant box by running `vagrant up`, vagrant will mount pre-defined directories on the guest onto the host machine (your local desktop). 
This way you can work locally and make changes in your preferred IDE and view the results by visiting the vagrant box in your browser. 

These shared directories are defined in local.yml, a configuration file created when you run `vagrant up` for the first time:

```
    fs:
      folders:
        magento1:
          host: data/web/public
          guest: /data/web/public
        nginx:
          host: data/web/nginx/
          guest: /data/web/nginx/
      type: virtualbox
      disabled_folders:
        magento2:
          host: data/web/magento2
          guest: /data/web/magento2
```

All mountpoints defined in `folders` that have their own `host` and `guest` paths are mounted when setting up. 
If you want to add your own mountpoints, you can add your own section:

```
    folders:
      some_mount:
        host: my/dir
        guest: /some/path
```

Make sure you don't combine both magento2 and magento1 sections as they will be mounted on top of each other.


## Switching between magento1 and magento2

To switch between magento1 and magento2, change the `version` setting in the local.yml file:
```
    magento:
      version: 2
```

After changing the version, run `vagrant destroy && vagrant up` to remove the old node and boot up a new one.

Vagrant will notice the magento version changed and correct the shared folders settings accordingly:
```
    ==> hypernode: Disabling fs->folders->magento1 in the local.yml because Magento 2 was configured..
```


## Troubleshooting

### ==> default: stdin: is not a tty

This is Vagrant bug [#1673](https://github.com/mitchellh/vagrant/issues/1673) and perfectly harmless.

### The config reloader is not reloading on changes in /data/web/nginx

/data/web/nginx is an NFS mount on your local computer. We use inotify to detect changes in the config files, but NFS is not supporting inotify.
If you want to use automatic config reloads on nginx config changes, change the vagrant file to not use an nfs mount by uncommenting:

    config.vm.synced_folder "data/web/nginx/", "/data/web/nginx/", owner: "app", group: "app", create: true

And then manually sync your nginx config files to the hypernode vagrant box.

### [hypernode] GuestAdditions versions on your host (X.X.XX) and guest (X.X.XX) do not match.

This error appears when your VM GuestAdditions installed by virtualbox are older then the one used on the hypernode vagrant.
To resolve this, upgrade your virtualbox to the latest version.

### The web pages don't change

Varnish is NOT enabled by default but can be enabled in local.yml or by answering the configuration questions asked the first time `vagrant up` is executed (this will generate a local.yml)

If you enabled varnish however it's possible your pages are not changing due to caching.
To check if this is what is causing your pages to remain static try clearing the cache.

```
# this clears the entire varnish cache (warning: makes things slow until cache is filled up again)
varnishadm "ban req.url ~ /"
```

To completely disable Varnish caching
```
# Create a vcl that tells Varnish to cache nothing
echo -e 'vcl 4.0;\nbackend default {\n  .host = "127.0.0.1";\n  .port = "8080";\n}\nsub vcl_recv {\n  return(pass);\n}' > /data/web/disabled_caching.vcl

# Compile the vcl
varnishadm vcl.load nocache /data/web/disabled_caching.vcl

# Load the vcl
varnishadm vcl.use nocache
```

For more information about Varnish on Hypernode see [this knowledgebase article](https://support.hypernode.com/knowledgebase/varnish-on-hypernode/).

### Transfer closed with x bytes remaining to read

Sometimes there is a connection error while downloading or upgrading the vagrant box.

```
http://vagrant.hypernode.com/hypernode.vagrant.release-2653.box
An error occurred while downloading the remote file. The error message, if any, is reproduced below. Please fix this error and try again.

transfer closed with 675809792 bytes remaining to read
```

If you get this error you can continue the interrupted download with another ```vagrant up``` (or a ```vagrant box update``` if you have already installed a previous version of the box)
```
==> hypernode: Adding box 'hypernode' (v2653) for provider: virtualbox
    hypernode: Downloading: http://vagrant.hypernode.com/hypernode.vagrant.release-2653.box
==> hypernode: Box download is resuming from prior download progress
```
