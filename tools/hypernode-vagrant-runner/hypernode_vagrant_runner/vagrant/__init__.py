from logging import getLogger
from contextlib import contextmanager
from functools import partial

from hypernode_vagrant_runner.settings import HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION
from hypernode_vagrant_runner.utils import run_local_command
from hypernode_vagrant_runner.vagrant.set_up import create_hypernode_vagrant
from hypernode_vagrant_runner.vagrant.tear_down import destroy_hypernode_vagrant, remove_hypernode_vagrant

log = getLogger(__name__)


def get_networking_information_from_vagrant(directory):
    """
    Return a dict with networking information from the running Vagrant in
    the specified directory
    :param str directory: Directory to get the networking information from
    :return dict vagrant_ssh_config: Parsed vagrant ssh-config output
    """
    get_attribute = "cd {directory} && " \
                    "vagrant ssh-config | " \
                    "grep {attribute} | " \
                    "awk '{{print $NF}}'"
    get_attribute_from_vagrant = partial(
        get_attribute.format, directory=directory
    )
    vagrant_ssh_config = {
        attribute: run_local_command(
            get_attribute_from_vagrant(attribute=attribute), shell=True
        ).strip() for attribute in ('HostName', 'Port', 'IdentityFile')
    }
    log.info("Retrieved networking info from {}: {}"
             "".format(directory, vagrant_ssh_config))
    return vagrant_ssh_config


@contextmanager
def hypernode_vagrant(directory=None, php_version=HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION,
                      xdebug_enabled=False, skip_try_sudo=False, xenial=False):
    """
    Run an ephemeral hypernode-vagrant and yield the connection details
    :param str directory: The hypernode-vagrant checkout to use.
    By default a temporary directory is created which is cleaned up
    after the context exits.
    :param str php_version: The PHP version to use
    :param bool xdebug_enabled: Install xdebug in the vagrant
    :param bool skip_try_sudo: Skip try to sudo beforehand to fail early
    ;param bool xenial: Start a Xenial image
    :yield dict vagrant_ssh_config: Parsed vagrant ssh-config
    """
    checkout_directory = create_hypernode_vagrant(
        directory=directory, php_version=php_version,
        xdebug_enabled=xdebug_enabled, skip_try_sudo=skip_try_sudo,
        xenial=xenial
    )
    try:
        yield get_networking_information_from_vagrant(checkout_directory)
    finally:
        # Only clean up if a temporary directory was used
        if not directory:
            destroy_hypernode_vagrant(checkout_directory)
            remove_hypernode_vagrant(checkout_directory)
