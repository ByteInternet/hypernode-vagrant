from hypernode_vagrant_runner.vagrant.set_up import run_vagrant_up
from tests.testcase import TestCase


class TestRunVagrantUp(TestCase):
    def setUp(self):
        self.run_local_command = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.set_up.run_local_command'
        )

    def test_run_vagrant_up_starts_vagrant_in_shell_in_specific_directory(self):
        run_vagrant_up('/tmp/tmpdir1234')

        self.run_local_command.assert_called_once_with(
            'cd /tmp/tmpdir1234 && vagrant up',
            shell=True
        )
