from sys import stdout

from hypernode_vagrant_runner.runner import run_command_in_vagrant
from hypernode_vagrant_runner.settings import HYPERNODE_VAGRANT_DEFAULT_USER
from tests.testcase import TestCase


class TestRunCommandInVagrant(TestCase):
    def setUp(self):
        self.wrap_ssh_call = self.set_up_patch(
            'hypernode_vagrant_runner.runner.remote_command.wrap_ssh_call'
        )
        self.vagrant_ssh_config = {
            'HostName': '127.0.0.1',
            'Port': '2222',
            'IdentityFile': '/tmp/tmpZrTKrM/.vagrant/machines/hypernode/virtualbox/private_key'
        }
        self.check_call = self.set_up_patch(
            'hypernode_vagrant_runner.runner.remote_command.check_call'
        )

    def test_run_command_in_vagrant_wraps_ssh_call(self):
        run_command_in_vagrant('bash runtests.sh', self.vagrant_ssh_config)

        self.wrap_ssh_call.assert_called_once_with(
            self.vagrant_ssh_config,
            ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER,
            command_to_run='bash runtests.sh'
        )

    def test_run_command_in_vagrant_wraps_ssh_call_as_specified_user(self):
        run_command_in_vagrant('bash runtests.sh', self.vagrant_ssh_config,
                               ssh_user='root')

        self.wrap_ssh_call.assert_called_once_with(
            self.vagrant_ssh_config,
            ssh_user='root',
            command_to_run='bash runtests.sh'
        )

    def test_run_command_in_vagrant_runs_local_command(self):
        run_command_in_vagrant('bash runtests.sh', self.vagrant_ssh_config)

        self.check_call.assert_called_once_with(
            self.wrap_ssh_call.return_value, shell=True,
            stdout=stdout, bufsize=1
        )
