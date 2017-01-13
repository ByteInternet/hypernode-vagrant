from hypernode_vagrant_runner.runner import launch_runner
from hypernode_vagrant_runner.settings import HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION, HYPERNODE_VAGRANT_DEFAULT_USER
from tests.testcase import TestCase


class TestLaunchRunner(TestCase):
    def setUp(self):
        self.hypernode_vagrant = self.set_up_patch(
            'hypernode_vagrant_runner.runner.hypernode_vagrant'
        )
        self.hypernode_vagrant.return_value.__exit__ = lambda a, b, c, d: None
        self.vagrant_ssh_config = {
            'HostName': '127.0.0.1',
            'Port': '2222',
            'IdentityFile': '/tmp/tmpZrTKrM/.vagrant/machines/hypernode/virtualbox/private_key'
        }
        self.hypernode_vagrant.return_value.__enter__ = lambda _: self.vagrant_ssh_config
        self.loop_run_project_command_in_vagrant = self.set_up_patch(
            'hypernode_vagrant_runner.runner.loop_run_project_command_in_vagrant'
        )
        self.run_project_command_in_vagrant = self.set_up_patch(
            'hypernode_vagrant_runner.runner.run_project_command_in_vagrant'
        )

    def test_launch_runner_uses_hypernode_vagrant_context(self):
        launch_runner()

        self.hypernode_vagrant.assert_called_once_with(
            directory=None,
            php_version=HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION,
            xdebug_enabled=False,
            skip_try_sudo=False
        )

    def test_launch_runner_uses_hypernode_vagrant_context_from_specified_pre_existing_checkout(self):
        launch_runner(
            directory='/home/some_user/code/projects/hypernode-vagrant'
        )

        self.hypernode_vagrant.assert_called_once_with(
            directory='/home/some_user/code/projects/hypernode-vagrant',
            php_version=HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION,
            xdebug_enabled=False,
            skip_try_sudo=False
        )

    def test_launch_runner_uses_hypernode_vagrant_context_with_specific_php_version(self):
        launch_runner(
            php_version='5.5'
        )

        self.hypernode_vagrant.assert_called_once_with(
            directory=None,
            php_version='5.5',
            xdebug_enabled=False,
            skip_try_sudo=False
        )

    def test_launch_runner_uses_hypernode_vagrant_context_with_xdebug_enabled_if_specified(self):
        launch_runner(
            xdebug_enabled=True
        )

        self.hypernode_vagrant.assert_called_once_with(
            directory=None,
            php_version=HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION,
            xdebug_enabled=True,
            skip_try_sudo=False
        )

    def test_launch_runner_runs_project_command_in_context(self):
        launch_runner()

        self.run_project_command_in_vagrant.assert_called_once_with(
            None, None,
            vagrant_info=self.vagrant_ssh_config,
            ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER
        )

    def test_launch_runner_runs_project_command_in_context_using_specified_user(self):
        launch_runner(ssh_user='root')

        self.run_project_command_in_vagrant.assert_called_once_with(
            None, None,
            vagrant_info=self.vagrant_ssh_config,
            ssh_user='root'
        )

    def test_launch_runner_runs_project_command_in_context_using_specified_project_path(self):
        launch_runner(
            project_path='/home/some_user/code/projects/hypernode-magerun'
        )

        self.run_project_command_in_vagrant.assert_called_once_with(
            '/home/some_user/code/projects/hypernode-magerun',
            None,
            vagrant_info=self.vagrant_ssh_config,
            ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER
        )

    def test_launch_runner_loops_run_project_command_in_context_using_specified_command_to_run(self):
        launch_runner(
            command_to_run='bash build/vagrant/setup_and_run_tests.sh'
        )

        self.loop_run_project_command_in_vagrant.assert_called_once_with(
            None,
            'bash build/vagrant/setup_and_run_tests.sh',
            vagrant_info=self.vagrant_ssh_config,
            ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER
        )

    def test_launch_runner_loops_run_project_command_in_context_using_both_project_path_and_command(self):
        launch_runner(
            project_path='/home/some_user/code/projects/hypernode-magerun',
            command_to_run='bash build/vagrant/setup_and_run_tests.sh'
        )

        self.loop_run_project_command_in_vagrant.assert_called_once_with(
            '/home/some_user/code/projects/hypernode-magerun',
            'bash build/vagrant/setup_and_run_tests.sh',
            vagrant_info=self.vagrant_ssh_config,
            ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER
        )

    def test_launch_runner_does_not_loop_run_project_command_if_run_once_and_command_to_run_specified(self):
        launch_runner(
            run_once=True,
            command_to_run='bash build/vagrant/setup_and_run_tests.sh'
        )

        self.assertFalse(self.loop_run_project_command_in_vagrant.called)

    def test_launch_runner_runs_project_command_in_context_if_run_once_and_command_to_run_specified(self):
        launch_runner(
            run_once=True,
            command_to_run='bash build/vagrant/setup_and_run_tests.sh'
        )

        self.run_project_command_in_vagrant.assert_called_once_with(
            None,
            'bash build/vagrant/setup_and_run_tests.sh',
            vagrant_info=self.vagrant_ssh_config,
            ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER
        )

    def test_launch_runner_runs_project_command_in_context_if_run_once_and_command_to_run_and_project_specified(self):
        launch_runner(
            project_path='/home/some_user/code/projects/hypernode-magerun',
            run_once=True,
            command_to_run='bash build/vagrant/setup_and_run_tests.sh'
        )

        self.run_project_command_in_vagrant.assert_called_once_with(
            '/home/some_user/code/projects/hypernode-magerun',
            'bash build/vagrant/setup_and_run_tests.sh',
            vagrant_info=self.vagrant_ssh_config,
            ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER
        )
