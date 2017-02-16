from logging import getLogger
from subprocess import CalledProcessError, check_call

from os import system
from sys import stdout

from hypernode_vagrant_runner.settings import HYPERNODE_VAGRANT_DEFAULT_USER, \
    UPLOAD_PATH

try:
    # Import quote from shlex in case of python 3
    from shlex import quote
except ImportError:
    # In python 2 fall back to quote from pipes
    from pipes import quote

log = getLogger(__name__)


def wrap_ssh_call(vagrant_info, command_to_run='', ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER):
    """
    Wrap a string in an ssh call to perform that command on a remote host
    :param dict vagrant_info: The vagrant ssh-config connection details
    :param str command_to_run: The command to run
    :param str ssh_user: The SSH user to run the call as
    :return str ssh_wrapper_command: The ssh command to run
    """
    command = quote('sh -c \'cd {} && {}\''.format(
        UPLOAD_PATH,
        command_to_run)
    ) if command_to_run else ''
    ssh_wrapper_command = 'ssh ' \
                          '-oStrictHostKeyChecking=no ' \
                          '-oUserKnownHostsFile=/dev/null ' \
                          '-i {IdentityFile} -p {Port} {user}@{HostName} ' \
                          '{remote_command}' \
                          ''.format(user=ssh_user,
                                    remote_command=command,
                                    **vagrant_info)
    log.debug("Wrapped SSH command: {}".format(ssh_wrapper_command))
    return ssh_wrapper_command


def run_command_in_vagrant(command_to_run, vagrant_info,
                           ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER):
    """
    Run a command in the remote vagrant
    :param str command_to_run: The command to run
    :param dict vagrant_info: The vagrant ssh-config connection details
    :param str ssh_user: The SSH user to run the command as
    :return None:
    """
    log.info("Running command in the vagrant environment")
    ssh_wrapper_command = wrap_ssh_call(
        vagrant_info, ssh_user=ssh_user, command_to_run=command_to_run
    )
    try:
        check_call(ssh_wrapper_command, shell=True, stdout=stdout, bufsize=1)
    except CalledProcessError:
        log.info("Running command in Vagrant exited nonzero")


def get_remote_shell(vagrant_info, ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER):
    """
    Get a remote shell
    :param dict vagrant_info: The vagrant ssh-config connection details
    :param str ssh_user: The SSH user to get the shell as
    :return None:
    """
    log.info("Getting remote shell on {HostName}:{Port}".format(
        **vagrant_info
    ))
    shell_command = wrap_ssh_call(vagrant_info, ssh_user=ssh_user)
    system(shell_command)
