from hypernode_vagrant_runner.runner import run_project_command_in_vagrant
from hypernode_vagrant_runner.settings import HYPERNODE_VAGRANT_DEFAULT_USER
from tests.testcase import TestCase


class TestRunProjectCommandInVagrant(TestCase):
    def setUp(self):
        self.upload_project_to_vagrant = self.set_up_patch(
            'hypernode_vagrant_runner.runner.upload_project_to_vagrant'
        )
        self.vagrant_ssh_config = {
            'HostName': '127.0.0.1',
            'Port': '2222',
            'IdentityFile': '/tmp/tmpZrTKrM/.vagrant/machines/hypernode/virtualbox/private_key'
        }
        self.get_remote_shell = self.set_up_patch(
            'hypernode_vagrant_runner.runner.get_remote_shell'
        )
        self.run_command_in_vagrant = self.set_up_patch(
            'hypernode_vagrant_runner.runner.run_command_in_vagrant'
        )

    def test_run_project_command_in_vagrant_does_not_upload_project_to_vagrant_if_no_project_path(self):
        run_project_command_in_vagrant(
            project_path=None,
            command_to_run=None,
            vagrant_info=self.vagrant_ssh_config
        )

        self.assertFalse(self.upload_project_to_vagrant.called)

    def test_run_project_command_in_vagrant_uploads_project_to_vagrant_if_project_path_specified(self):
        run_project_command_in_vagrant(
            project_path='/home/some_user/code/projects/hypernode-magerun',
            command_to_run=None,
            vagrant_info=self.vagrant_ssh_config
        )

        self.upload_project_to_vagrant.assert_called_once_with(
            '/home/some_user/code/projects/hypernode-magerun',
            self.vagrant_ssh_config,
            ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER
        )

    def test_run_project_command_in_vagrant_uploads_project_to_vagrant_as_specified_user(self):
        run_project_command_in_vagrant(
            project_path='/home/some_user/code/projects/hypernode-magerun',
            command_to_run=None,
            vagrant_info=self.vagrant_ssh_config,
            ssh_user='root'
        )

        self.upload_project_to_vagrant.assert_called_once_with(
            '/home/some_user/code/projects/hypernode-magerun',
            self.vagrant_ssh_config,
            ssh_user='root'
        )

    def test_run_project_command_in_vagrant_gets_remote_shell_if_no_command_specified(self):
        run_project_command_in_vagrant(
            project_path=None,
            command_to_run=None,
            vagrant_info=self.vagrant_ssh_config
        )

        self.get_remote_shell.assert_called_once_with(
            self.vagrant_ssh_config, ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER
        )

    def test_run_project_command_in_vagrant_gets_remote_shell_as_specified_user_if_no_command_specified(self):
        run_project_command_in_vagrant(
            project_path=None,
            command_to_run=None,
            vagrant_info=self.vagrant_ssh_config,
            ssh_user='root'
        )

        self.get_remote_shell.assert_called_once_with(
            self.vagrant_ssh_config, ssh_user='root'
        )

    def tst_run_project_command_in_vagrant_does_not_run_command_in_vagrant_if_no_command_specified(self):
        run_project_command_in_vagrant(
            project_path=None,
            command_to_run=None,
            vagrant_info=self.vagrant_ssh_config,
        )

        self.assertFalse(self.run_command_in_vagrant.called)

    def test_run_project_command_in_vagrant_runs_specified_command_in_vagrant(self):
        run_project_command_in_vagrant(
            project_path=None,
            command_to_run='bash build/vagrant/setup_and_run_tests.sh',
            vagrant_info=self.vagrant_ssh_config,
        )

        self.run_command_in_vagrant.assert_called_once_with(
            'bash build/vagrant/setup_and_run_tests.sh',
            self.vagrant_ssh_config,
            ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER
        )

    def test_run_project_command_in_vagrant_runs_specified_command_in_vagrant_as_specified_user(self):
        run_project_command_in_vagrant(
            project_path=None,
            command_to_run='bash build/vagrant/setup_and_run_tests.sh',
            vagrant_info=self.vagrant_ssh_config,
            ssh_user='root'
        )

        self.run_command_in_vagrant.assert_called_once_with(
            'bash build/vagrant/setup_and_run_tests.sh',
            self.vagrant_ssh_config,
            ssh_user='root'
        )
