from argparse import ArgumentParser

from hypernode_vagrant_runner.log import setup_logging
from hypernode_vagrant_runner.runner import launch_runner
from hypernode_vagrant_runner.settings import HYPERNODE_VAGRANT_PHP_VERSIONS, HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION, \
    HYPERNODE_VAGRANT_DEFAULT_USER, HYPERNODE_VAGRANT_USERS, UPLOAD_PATH


def parse_arguments(parser):
    """
    Add default parser argument to parser, parse the arguments and set the
    logging level.
    :param obj parser: A parser object
    :return obj args: The parsed arguments
    """
    parser.add_argument('--verbose', '-v', action='store_true')
    args = parser.parse_args()
    setup_logging(debug=args.verbose)
    return args


def parse_start_runner_arguments():
    """
    Parse the commandline options for starting the runner
    :return obj args: parsed args
    """
    parser = ArgumentParser(
        prog='hypernode-vagrant-runner',
        description='Run a project inside a hypernode-vagrant'
    )
    parser.add_argument(
        '--run-once', '-1',
        action='store_true',
        help='Run the provided hook once and destroy the machine. '
             'Default persists the machine until CTRL + C'
    )
    parser.add_argument(
        '--project-path',
        help='Path to upload to the {} directory. If specified the command '
             'wil be run in this directory. '
             'Example: ~/code/projects/your_shop'.format(UPLOAD_PATH)
    )
    parser.add_argument(
        '--command-to-run', '-c',
        help='The command to run in the uploaded directory. '
             'Example: -c "sh runtests.sh"'
    )
    parser.add_argument(
        '--pre-existing-vagrant-path', '-p',
        help='Path to an existing hypernode-vagrant checkout. '
             'By default a new checkout in a temporary directory '
             'is used'
    )
    parser.add_argument(
        '--php',
        help='Specify a PHP version. Default is '
             '{}'.format(HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION),
        choices=HYPERNODE_VAGRANT_PHP_VERSIONS,
        default=HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION
    )
    parser.add_argument(
        '--enable-xdebug',
        action='store_true',
        help='Enable xdebug in the Vagrant'
    )
    parser.add_argument(
        '--user',
        help='The SSH user to run the command as. Default is '
             '{}'.format(HYPERNODE_VAGRANT_DEFAULT_USER),
        choices=HYPERNODE_VAGRANT_USERS,
        default=HYPERNODE_VAGRANT_DEFAULT_USER
    )
    return parse_arguments(parser)


def start_runner():
    """
    Start a hypernode vagrant and run the provided hook
    :return None:
    """
    args = parse_start_runner_arguments()
    launch_runner(
        project_path=args.project_path,
        command_to_run=args.command_to_run,
        run_once=args.run_once,
        directory=args.pre_existing_vagrant_path,
        php_version=args.php,
        ssh_user=args.user,
        xdebug_enabled=args.enable_xdebug
    )
