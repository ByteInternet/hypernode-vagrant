.PHONY: all clean

NAME := vagrant-hypconfigmgmt
VERSION := 0.1
MAINTAINER := Rick van de Loo <rick@byte.nl>
DESCRIPTION := Prompt to configure a hypernode-vagrant

all:
	rake build
install:
	find pkg/ | tail -n 1 | xargs vagrant plugin install
clean:
	git clean -xfd

