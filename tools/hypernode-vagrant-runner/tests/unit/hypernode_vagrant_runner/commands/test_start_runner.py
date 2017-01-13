from hypernode_vagrant_runner.commands import start_runner
from tests.testcase import TestCase


class TestStartRunner(TestCase):
    def setUp(self):
        self.parse_start_runner_arguments = self.set_up_patch(
            'hypernode_vagrant_runner.commands.parse_start_runner_arguments'
        )
        self.args = self.parse_start_runner_arguments.return_value
        self.launch_runner = self.set_up_patch(
            'hypernode_vagrant_runner.commands.launch_runner'
        )

    def test_start_runner_parses_start_runner_arguments(self):
        start_runner()

        self.parse_start_runner_arguments.assert_called_once_with()

    def test_start_runner_launches_runner(self):
        start_runner()

        self.launch_runner.assert_called_once_with(
            project_path=self.args.project_path,
            command_to_run=self.args.command_to_run,
            run_once=self.args.run_once,
            directory=self.args.pre_existing_vagrant_path,
            php_version=self.args.php,
            ssh_user=self.args.user,
            xdebug_enabled=self.args.enable_xdebug,
            skip_try_sudo=self.args.skip_try_sudo
        )
