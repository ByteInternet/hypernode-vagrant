.PHONY: devenv update clean

NAME := magento2 shop
VERSION := 0.1
MAINTAINER := Rick van de Loo <rick@byte.nl>
DESCRIPTION := My demo Magento 2 shop for testing purposes

devenv:
	scripts/check_env.sh
	scripts/boot_vagrant.sh
	scripts/deploy_development.sh
update:
	scripts/check_env.sh
	scripts/deploy_development.sh
clean:
	[ -d hypernode-vagrant ] && (cd hypernode-vagrant && vagrant destroy -f) || /bin/true
	rm -Rf hypernode-vagrant
	git clean -xfd
