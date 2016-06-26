#!/bin/sh

set -e 

DIRNAME="$(dirname 0)"

# validate local.example.yml
echo -n "Checking base configuration file is valid YAML.. "
ruby -e "require 'yaml';YAML.load_file('$DIRNAME/.local.base.yml')" \
	&& echo "\033[0;32mOK\033[0m" \
	|| (echo "\033[0;31mlocal.example.yml is not valid yaml\033[0m" && /bin/false)

echo "Running vagrant-hypconfigmgmt tests.."
# run vagrant-hypconfigmgmt tests
(cd "$DIRNAME/vagrant/plugins/vagrant-hypconfigmgmt/" && make test)
