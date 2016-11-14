from mock import call, ANY

from hypernode_vagrant_runner.runner import loop_run_project_command_in_vagrant
from hypernode_vagrant_runner.settings import HYPERNODE_VAGRANT_DEFAULT_USER
from tests.testcase import TestCase


class TestLoopRunProjectCommandInVagrant(TestCase):
    def setUp(self):
        self.run_project_command_in_vagrant = self.set_up_patch(
            'hypernode_vagrant_runner.runner.run_project_command_in_vagrant'
        )
        self.run_project_command_in_vagrant.side_effect = [None, None, KeyboardInterrupt]
        self.input = self.set_up_patch(
            'hypernode_vagrant_runner.runner.input'
        )
        self.input.return_value = ''
        self.vagrant_ssh_config = {
            'HostName': '127.0.0.1',
            'Port': '2222',
            'IdentityFile': '/tmp/tmpZrTKrM/.vagrant/machines/hypernode/virtualbox/private_key'
        }
        self.get_remote_shell = self.set_up_patch(
            'hypernode_vagrant_runner.runner.get_remote_shell'
        )

    def test_loop_run_project_command_in_vagrant_runs_project_command_in_vagrant_until_sigterm(self):
        loop_run_project_command_in_vagrant(
            '/home/some_user/code/projects/hypernode-magerun',
            'bash build/vagrant/setup_and_run_tests.sh',
            self.vagrant_ssh_config,
        )

        expected_calls = [
            call(
                '/home/some_user/code/projects/hypernode-magerun',
                'bash build/vagrant/setup_and_run_tests.sh',
                self.vagrant_ssh_config,
                ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER
            )
        ] * 3
        for expected_call in expected_calls:
            self.assertIn(expected_call, self.run_project_command_in_vagrant.mock_calls)

    def test_loop_run_project_command_in_vagrant_runs_project_command_in_vagrant_until_EOFError_from_input(self):
        self.input.side_effect = [None, EOFError]

        loop_run_project_command_in_vagrant(
                '/home/some_user/code/projects/hypernode-magerun',
                'bash build/vagrant/setup_and_run_tests.sh',
                self.vagrant_ssh_config,
        )

        expected_calls = [
             call(
                 '/home/some_user/code/projects/hypernode-magerun',
                 'bash build/vagrant/setup_and_run_tests.sh',
                 self.vagrant_ssh_config,
                 ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER
             )
         ] * 2
        for expected_call in expected_calls:
            self.assertIn(expected_call, self.run_project_command_in_vagrant.mock_calls)

    def test_loop_run_project_command_in_vagrant_runs_project_command_in_vagrant_as_specified_user_until_sigterm(self):
        loop_run_project_command_in_vagrant(
            '/home/some_user/code/projects/hypernode-magerun',
            'bash build/vagrant/setup_and_run_tests.sh',
            self.vagrant_ssh_config,
            ssh_user='root'
        )

        expected_calls = [
             call(
                 '/home/some_user/code/projects/hypernode-magerun',
                 'bash build/vagrant/setup_and_run_tests.sh',
                 self.vagrant_ssh_config,
                 ssh_user='root'
             )
         ] * 3
        for expected_call in expected_calls:
            self.assertIn(expected_call, self.run_project_command_in_vagrant.mock_calls)

    def test_loop_run_project_command_in_vagrant_blocks_for_input_after_iteration(self):
        loop_run_project_command_in_vagrant(
            '/home/some_user/code/projects/hypernode-magerun',
            'bash build/vagrant/setup_and_run_tests.sh',
            self.vagrant_ssh_config,
        )

        # Only 2, not three. Stopped after the second iteration.
        self.assertEqual(2, self.input.call_count)

    def test_loop_run_project_command_in_vagrant_does_not_get_remote_shell_if_input_is_enter(self):
        self.run_project_command_in_vagrant.side_effect = [None, KeyboardInterrupt]

        loop_run_project_command_in_vagrant(
            '/home/some_user/code/projects/hypernode-magerun',
            'bash build/vagrant/setup_and_run_tests.sh',
            self.vagrant_ssh_config,
        )

        self.assertFalse(self.get_remote_shell.called)

    def test_loop_run_project_command_in_vagrant_gets_remote_shell_if_input_is_capital_S(self):
        self.run_project_command_in_vagrant.side_effect = [None, KeyboardInterrupt]
        self.input.return_value = 'S'

        loop_run_project_command_in_vagrant(
            '/home/some_user/code/projects/hypernode-magerun',
            'bash build/vagrant/setup_and_run_tests.sh',
            self.vagrant_ssh_config,
        )

        self.get_remote_shell.assert_called_once_with(
            self.vagrant_ssh_config, ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER
        )

    def test_loop_run_project_command_in_vagrant_gets_remote_shell_if_input_is_normal_s(self):
        self.run_project_command_in_vagrant.side_effect = [None, KeyboardInterrupt]
        self.input.return_value = 's'

        loop_run_project_command_in_vagrant(
            '/home/some_user/code/projects/hypernode-magerun',
            'bash build/vagrant/setup_and_run_tests.sh',
            self.vagrant_ssh_config,
        )

        self.get_remote_shell.assert_called_once_with(
            self.vagrant_ssh_config, ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER
        )

    def test_loop_run_project_command_in_vagrant_gets_remote_shell_if_input_starts_with_s(self):
        self.run_project_command_in_vagrant.side_effect = [None, KeyboardInterrupt]
        self.input.return_value = 'shell'

        loop_run_project_command_in_vagrant(
            '/home/some_user/code/projects/hypernode-magerun',
            'bash build/vagrant/setup_and_run_tests.sh',
            self.vagrant_ssh_config,
        )

        self.get_remote_shell.assert_called_once_with(
            self.vagrant_ssh_config, ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER
        )
