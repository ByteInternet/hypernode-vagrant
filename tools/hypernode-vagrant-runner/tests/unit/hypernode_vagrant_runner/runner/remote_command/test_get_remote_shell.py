from hypernode_vagrant_runner.runner import get_remote_shell
from hypernode_vagrant_runner.settings import HYPERNODE_VAGRANT_DEFAULT_USER
from tests.testcase import TestCase


class TestGetRemoteShell(TestCase):
    def setUp(self):
        self.wrap_ssh_call = self.set_up_patch(
            'hypernode_vagrant_runner.runner.remote_command.wrap_ssh_call'
        )
        self.vagrant_ssh_config = {
            'HostName': '127.0.0.1',
            'Port': '2222',
            'IdentityFile': '/tmp/tmpZrTKrM/.vagrant/machines/hypernode/virtualbox/private_key'
        }
        self.system = self.set_up_patch(
            'hypernode_vagrant_runner.runner.remote_command.system'
        )

    def test_get_remote_shell_wraps_ssh_call(self):
        get_remote_shell(self.vagrant_ssh_config)

        self.wrap_ssh_call.assert_called_once_with(
            self.vagrant_ssh_config, ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER
        )

    def test_get_remote_shell_wraps_ssh_call_using_specified_ssh_user(self):
        get_remote_shell(self.vagrant_ssh_config, ssh_user='root')

        self.wrap_ssh_call.assert_called_once_with(
            self.vagrant_ssh_config, ssh_user='root'
        )

    def test_remote_remote_shell_gets_shell_and_returns_control_back_to_the_user(self):
        get_remote_shell(self.vagrant_ssh_config)

        self.system.assert_called_once_with(self.wrap_ssh_call.return_value)
