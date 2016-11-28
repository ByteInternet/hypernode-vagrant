from logging import getLogger

try:
    # In case of python 2 assign raw_input to input
    input = raw_input
except NameError:
    # In python 3 raw_input was removed and renamed to input
    pass

from hypernode_vagrant_runner.runner.remote_command import run_command_in_vagrant, get_remote_shell
from hypernode_vagrant_runner.runner.upload import upload_project_to_vagrant
from hypernode_vagrant_runner.settings import HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION, HYPERNODE_VAGRANT_DEFAULT_USER
from hypernode_vagrant_runner.vagrant import hypernode_vagrant

log = getLogger(__name__)


def run_project_command_in_vagrant(project_path, command_to_run, vagrant_info,
                                   ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER):
    """
    Upload the project if one is specified and run the command.
    If no command is specified, get a shell.
    :param str project_path: The project path to upload to the vagrant before
    running the specified command in that directory in the vagrant
    :param str command_to_run: The shell command to run in the uploaded
    project_path
    :param dict vagrant_info: The vagrant ssh-config connection details
    :param str ssh_user: The SSH user to use to run the hook as
    :return None:
    """
    # If a project path was specified, upload that directory
    if project_path:
        upload_project_to_vagrant(project_path, vagrant_info)

    if command_to_run:
        # If a command was specified run that command
        run_command_in_vagrant(command_to_run, vagrant_info, ssh_user=ssh_user)
    else:
        # Otherwise log in to the remote machine and return control to the user
        get_remote_shell(vagrant_info, ssh_user=ssh_user)


def loop_run_project_command_in_vagrant(project_path, command_to_run,
                                        vagrant_info,
                                        ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER):
    """
    Loop running the project command in the vagrant on input
    :param str project_path: The project path to upload to the vagrant before
    running the specified command in that directory in the vagrant
    :param str command_to_run: The shell command to run in the uploaded
    project_path
    :param dict vagrant_info: The vagrant ssh-config connection details
    :param str ssh_user: The SSH user to use to run the hook as
    :return None:
    """
    log.info("Starting command loop.")
    try:
        while True:
            run_project_command_in_vagrant(
                project_path, command_to_run, vagrant_info, ssh_user=ssh_user
            )
            key = input(
                "\nPress enter to run the run the command again.\n"
                "S + Enter to get a shell.\nCTRL + C to stop the loop.\n> "
            )
            if key and key.strip().lower().startswith('s'):
                get_remote_shell(vagrant_info, ssh_user=ssh_user)

    except (KeyboardInterrupt, EOFError):
        log.info("Interrupt received. Terminating loop.")


def launch_runner(project_path=None, command_to_run=None,
                  run_once=False, directory=None,
                  php_version=HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION,
                  ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER,
                  xdebug_enabled=False
                  ):
    """
    Run the hook inside an ephemeral hypernode-vagrant context
    :param str project_path: The project path to upload to the vagrant before
    running the specified command in that directory in the vagrant
    :param str command_to_run: The shell command to run in the uploaded
    project_path
    :param bool run_once: Run once and clean up, default blocks in
    the context and waits for signals.
    :param str directory: The hypernode-vagrant checkout to use.
    By default a temporary directory with a fresh checkout is created
    :param str php_version: The PHP version to use
    :param str ssh_user: The SSH user to use to run the hook as
    :param bool xdebug_enabled: Install xdebug in the vagrant
    :return None:
    """
    with hypernode_vagrant(
        directory=directory, php_version=php_version, xdebug_enabled=xdebug_enabled
    ) as info:
        runner = run_project_command_in_vagrant if \
            run_once or not command_to_run else loop_run_project_command_in_vagrant
        runner(
            project_path, command_to_run,
            vagrant_info=info, ssh_user=ssh_user
        )
