# Arch Linux setup

Before you continue, understand that we provide this documentation as a reference but the hypernode-vagrant box does not officially support Arch Linux. We have made the box with Ubuntu and MacOSX in mind so at any time incompatibilities could pop up. Arch is a somewhat advanced distribution and the flexibility allows for great heterogeneity between configurations. If you do not wish to get your hands dirty and spend potentially considerable time debugging we recommend that you run the box on one of the aforementioned operating systems instead.

This document is a step by step guide on how to set up hypernode-vagrant on a fresh [Arch Linux](https://www.archlinux.org/) installation. Getting the box to run on Arch Linux is a bit more laborious than getting it to run on Ubuntu because on Arch you have to set up the [lxc](https://linuxcontainers.org/) container's networking yourself.

Note that these instructions assume that the user is root and that the lxc is not an unprivileged container. To set it up for less privileged users take note of [the vagrant-lxc sudo wrapper](https://github.com/fgrehm/vagrant-lxc/blob/97b5882262fcc5c652123c88515b8f925c42f574/lib/vagrant-lxc/sudo_wrapper.rb#L10) and keep an eye on [this thread about using unprivileged containers](https://github.com/fgrehm/vagrant-lxc/issues/312).  

If you encounter any issues relating to `vagrant-lxc` and not `hypernode-vagrant`, please use the search function [here](https://github.com/fgrehm/vagrant-lxc/issues) to see if someone else encountered it before and if there's a suggested fix.

### Install the requirements

```bash
pacman -S rsync dnsmasq git lxc vagrant --needed --noconfirm
```

You will also need to install [redir](https://linux.die.net/man/1/redir). Alternatively you could hack the lines with `config.vm.network "forwarded_port"` out of the Vagrantfile.  

### Create the configuration file for the LXC's NAT bridge

For more information about this and the following step see the host network configuration setting section of [this article about Linux Containers](https://wiki.archlinux.org/index.php/Linux_Containers) on the ArchWiki.

```bash
cat << EOF > /etc/default/lxc-net
# Leave USE_LXC_BRIDGE as "true" if you want to use lxcbr0 for your
# containers.  Set to "false" if you'll use virbr0 or another existing
# bridge, or mavlan to your host's NIC.
USE_LXC_BRIDGE="true"

# If you change the LXC_BRIDGE to something other than lxcbr0, then
# you will also need to update your /etc/lxc/default.conf as well as the
# configuration (/var/lib/lxc/<container>/config) for any containers
# already created using the default config to reflect the new bridge
# name.
# If you have the dnsmasq daemon installed, you'll also have to update
# /etc/dnsmasq.d/lxc and restart the system wide dnsmasq daemon.
LXC_BRIDGE="lxcbr0"
LXC_ADDR="10.0.3.1"
LXC_NETMASK="255.255.255.0"
LXC_NETWORK="10.0.3.0/24"
LXC_DHCP_RANGE="10.0.3.2,10.0.3.254"
LXC_DHCP_MAX="253"
# Uncomment the next line if you'd like to use a conf-file for the lxcbr0
# dnsmasq.  For instance, you can use 'dhcp-host=mail1,10.0.3.100' to have
# container 'mail1' always get ip address 10.0.3.100.
#LXC_DHCP_CONFILE=/etc/lxc/dnsmasq.conf

# Uncomment the next line if you want lxcbr0's dnsmasq to resolve the .lxc
# domain.  You can then add "server=/lxc/10.0.3.1' (or your actual $LXC_ADDR)
# to your system dnsmasq configuration file (normally /etc/dnsmasq.conf,
# or /etc/NetworkManager/dnsmasq.d/lxc.conf on systems that use NetworkManager).
# Once these changes are made, restart the lxc-net and network-manager services.
# 'container1.lxc' will then resolve on your host.
#LXC_DOMAIN="lxc"
EOF
```

### Modify the container template to use the bridge
```bash
cat << EOF > /etc/lxc/default.conf
lxc.net.0.type = veth
lxc.net.0.link = lxcbr0
lxc.net.0.flags = up
lxc.net.0.hwaddr = 00:16:3e:xx:xx:xx
EOF
```

### Start the bridge
```bash
# Start the service
systemctl start lxc-net

# And then if you want to make sure it is enabled on boot as well
systemctl enable lxc-net
```

### Clone the repository
```bash
git clone https://github.com/byteinternet/hypernode-vagrant
```

### Change directory to the new checkout
```
cd hypernode-vagrant
```

### Install the vagrant-lxc plugin
```
vagrant plugin install vagrant-lxc
```

### Make sure your SSH agent is running (optional)

If you do not want to log in with `vagrant ssh` but want to SSH directly into the box instead you need to run an SSH agent with one or more keys loaded when you run `vagrant up`. The [provisioning script](https://github.com/ByteInternet/hypernode-vagrant/blob/master/vagrant/provisioning/hypernode.sh#L40) will copy your public key to the box for the `root` user and the non-privileged `app` user.

```bash
eval $(ssh-agent -s); ssh-add
```

The reason why you might want to SSH directly into the box instead of connecting with `vagrant ssh` is that if you use SSH forwarding (`ssh -A`, for more info [see this nice article by GitHub](https://developer.github.com/v3/guides/using-ssh-agent-forwarding/)) you will be able to connect to your production Hypernode if it also has the public key in your agent in its authorized keys file. This can be desirable for when you want to use the [hypernode-importer](https://support.hypernode.com/knowledgebase/migrating-your-magento-to-hypernode/#Option_2_Migrate_your_shop_via_Shell_using_hypernode-importer_8211_Magento_1_2) to copy the shop from your production Hypernode into the local Vagrant.

### Initialize the environment
```bash
# So we do not accidentally use VirtualBox if that is also available on the system
export VAGRANT_DEFAULT_PROVIDER=lxc
vagrant up  # First run will install the 'vagrant-hypconfigmgmt' plugin
vagrant up  # Second run will prompt for settings like PHP 5 or 7?
vagrant up  # Will bring up the machine
```

For `lxc` make sure you have configured something other than `virtualbox` as the shared folder type. If you need two way sync I would suggest `nfs_guest` or `nfs`. 

If you do not care and just want it to work, run this to set it to `rsync`. This will only make it sync from the host to the guest (copy everything to the container) and requires no setup.

```bash
# Change the stored file share setting from virtualbox to rsync
sed 's/virtualbox/rsync/g' local.yml -i 
```

### Log in to the container

If you did not have an SSH agent running you should run:
```bash
# Log in as the default vagrant user
vagrant ssh

# And then inside the container:
# Switch to the root user
sudo su

# Or switch to the app user
sudo su app

# You can then change directory to the webroot
cd /data/web/public
```
