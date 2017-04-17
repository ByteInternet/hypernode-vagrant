from sys import stdout
from logging import getLogger
from os import geteuid
from subprocess import check_call, check_output, CalledProcessError

log = getLogger(__name__)


def try_sudo():
    """
    Try sudoing so if we need to be prompted for a password it happens
    now instead of later when the operator might not be watching the
    terminal anymore. If the user is root don't try sudoing.
    :return None:
    """
    if not geteuid() == 0:
        log.info("Testing we can sudo")
        check_call(
            "sudo echo 'yes we can sudo'",
            shell=True
        )


def is_python_3():
    """
    Return True if running in python 3, False if python 2
    Note: This function has no unit tests. If it does not work other tests
    will indirectly fail though.
    :return bool running_as_python_3: True if python 3, False if python 2
    """
    try:
        basestring
        return False
    except NameError:
        return True


def write_output_to_stdout(output):
    """
    Write to check_output output to standard out. In python 2 this is
    sys.stdout.write, in python 2 this is sys.stdout.buffer.write
    :param str output | obj output: check_output return value
    :return None:
    """
    try:
        stdout.buffer.write(output)
    except AttributeError:
        stdout.write(output)


def run_local_command(command, shell=False):
    """
    Run a command locally and print the output to stdout
    :param str command | iter command: The command to run.
    List if no shell, string if shell
    :param bool shell: Use a shell or not. Default expects no shell and thus
    the command as a list instead of a string
    :return str output: The output
    """
    try:
        output = check_output(command, shell=shell)
    except CalledProcessError as e:
        log.warning("Running command failed: {}".format(command))
        if e.output:
            write_output_to_stdout(e.output)
        if hasattr(e, 'stderr') and e.stderr:
            write_output_to_stdout(e.stderr)
        raise
    write_output_to_stdout(output)
    return output.decode('utf-8') if is_python_3() else output
