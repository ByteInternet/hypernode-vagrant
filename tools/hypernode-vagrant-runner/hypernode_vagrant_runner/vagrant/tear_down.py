from logging import getLogger
from shutil import rmtree

from hypernode_vagrant_runner.utils import run_local_command

log = getLogger(__name__)


def destroy_hypernode_vagrant(checkout_directory):
    """
    Destroy a hypernode-vagrant
    :param str checkout_directory: Path to the hypernode-vagrant checkout to destroy
    :return None:
    """
    log.info("Destroying Vagrant")
    vagrant_destroy_command = "cd {} && vagrant destroy -f".format(
        checkout_directory
    )
    run_local_command(vagrant_destroy_command, shell=True)


def remove_hypernode_vagrant(checkout_directory):
    """
    Remove the hypernode-vagrant checkout directory
    :param str checkout_directory: Path to the hypernode-vagrant checkout to remove
    :return None:
    """
    log.info("Cleaning up temporary hypernode-vagrant directory")
    rmtree(checkout_directory, ignore_errors=True)
