from logging import getLogger
from genericpath import isdir
from os import makedirs
from os.path import join
from tempfile import mkdtemp
from os.path import isfile

from hypernode_vagrant_runner.settings import HYPERNODE_VAGRANT_REPOSITORY, REQUIRED_VAGRANT_PLUGINS, \
    HYPERNODE_VAGRANT_CONFIGURATION, HYPERNODE_VAGRANT_BOX_NAMES, HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION, \
    HYPERNODE_VAGRANT_BOX_URLS, HYPERNODE_XENIAL_BOX_NAME, HYPERNODE_XENIAL_URL
from hypernode_vagrant_runner.utils import try_sudo, run_local_command

log = getLogger(__name__)


def ensure_directory(directory):
    """
    Create the directory if it does not exist
    :param str directory: Directory to create
    :return None:
    """
    if not isdir(directory):
        makedirs(directory)


def ensure_directory_for_checkout(directory=None):
    """
    Check if the specified directory exists, if no directory provided
    create a temporary directory and return the path.
    If a directory is specified and it does exist, raise an error.
    :param str directory: Name of the directory, None for temp dir
    :return str ensured_directory: path to the directory
    """
    log.info("Ensuring directory for checkout")
    if directory:
        ensure_directory(directory)
    else:
        log.info("Creating temporary directory")
    return directory or mkdtemp()


def is_hypernode_vagrant_directory(directory):
    """
    Check if a directory contains a hypernode-vagrant checkout
    :param str directory: The directory to check
    :return bool contains_vagrant: Whether or not the Vagrantfile is present
    """
    expected_vagrant_file = join(directory, 'Vagrantfile')
    return isfile(expected_vagrant_file)


def ensure_hypernode_vagrant_checkout(directory):
    """
    Ensure there is a hypernode-vagrant checkout in the
    specified directory
    :param str directory: Directory to specify the checkout in
    :return None:
    """
    if is_hypernode_vagrant_directory(directory):
        log.info("Found existing Vagrant file in directory")
    else:
        log.info("Cloning hypernode-vagrant")
        clone_command = [
            'git', 'clone', HYPERNODE_VAGRANT_REPOSITORY, directory
        ]
        run_local_command(clone_command)


def ensure_required_plugins_are_installed():
    """
    Ensure the required Vagrant plugins are installed
    :return None:
    """
    for plugin in REQUIRED_VAGRANT_PLUGINS:
        log.info("Ensuring Vagrant plugin {} is installed".format(plugin))
        ensure_installed = "vagrant plugin list | grep {} || " \
                           "vagrant plugin install {}".format(plugin, plugin)
        run_local_command(ensure_installed, shell=True)


def run_vagrant_up(directory, no_provision=False):
    """
    Run 'up' on the hypernode vagrant
    :param str directory: Directory to start the vagrant in
    :param bool no_provision: Pass --no-provision to vagrant up
    :return None:
    """
    log.info(
        "Running 'vagrant up' in the hypernode-vagrant "
        "checkout directory. This can take a while."
    )
    start_vagrant = 'cd {} && vagrant up'.format(directory)
    if no_provision:
        start_vagrant += ' --no-provision'
    run_local_command(start_vagrant, shell=True)


def write_hypernode_vagrant_configuration(
        directory,
        php_version=HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION,
        xdebug_enabled=False,
        xenial=False
):
    """
    Write the hypernode-vagrant local.yml configuration file to the
    hypernode-vagrant directory.
    :param str directory: The hypernode-vagrant checkout directory
    :param str php_version: The PHP version to use
    :param bool xdebug_enabled: Install xdebug in the vagrant
    ;param bool xenial: Configure a Xenial image
    :return None:
    """
    log.info("Writing configuration file to the hypernode-vagrant directory")
    local_yml_path = join(directory, 'local.yml')
    file_handle = open(local_yml_path, 'w')
    configuration = HYPERNODE_VAGRANT_CONFIGURATION.format(
        xdebug_enabled='true' if xdebug_enabled else 'false',
        php_version=php_version,
        box_name=HYPERNODE_XENIAL_BOX_NAME if xenial else HYPERNODE_VAGRANT_BOX_NAMES[
            php_version
        ],
        box_url=HYPERNODE_XENIAL_URL if xenial else HYPERNODE_VAGRANT_BOX_URLS[
            php_version
        ],
        ubuntu_version="xenial" if xenial else "precise"
    )
    file_handle.write(configuration)
    file_handle.close()


def start_hypernode_vagrant(directory,
                            php_version=HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION,
                            xdebug_enabled=False, xenial=False,
                            no_provision=False):
    """
    Write the configurations and start the Vagrant
    :param str directory: The directory in which to start the hypernode-vagrant
    :param str php_version: The PHP version to use
    :param bool xdebug_enabled: Install xdebug in the vagrant
    ;param bool xenial: Start a Xenial image
    :param bool no_provision: Pass --no-provision to vagrant up
    :return None:
    """
    write_hypernode_vagrant_configuration(
        directory, php_version=php_version,
        xdebug_enabled=xdebug_enabled, xenial=xenial,
    )
    run_vagrant_up(directory, no_provision=no_provision)


def create_hypernode_vagrant(directory=None,
                             php_version=HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION,
                             xdebug_enabled=False, skip_try_sudo=False,
                             xenial=False, no_provision=False):
    """
    Create a hypernode-vagrant
    :param str directory: Path to the hypernode-vagrant checkout,
    None for temporary directory
    :param str php_version: The PHP version to use
    :param bool xdebug_enabled: Install xdebug in the vagrant
    :param bool skip_try_sudo: Skip try to sudo beforehand to fail early
    ;param bool xenial: Start a Xenial image
    :param bool no_provision: Pass --no-provision to vagrant up
    :return str directory: Path to the hypernode-vagrant checkout
    None for a temp dir that will automatically be created
    """
    if not skip_try_sudo:
        try_sudo()
    clone_path = ensure_directory_for_checkout(directory=directory)
    ensure_hypernode_vagrant_checkout(directory=clone_path)
    ensure_required_plugins_are_installed()
    start_hypernode_vagrant(
        clone_path,
        php_version=php_version,
        xdebug_enabled=xdebug_enabled,
        xenial=xenial,
        no_provision=no_provision
    )
    return clone_path
