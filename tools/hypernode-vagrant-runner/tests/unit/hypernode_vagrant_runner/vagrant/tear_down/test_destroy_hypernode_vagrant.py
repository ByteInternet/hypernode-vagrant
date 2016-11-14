from hypernode_vagrant_runner.vagrant import destroy_hypernode_vagrant
from tests.testcase import TestCase


class TestDestroyHypernodeVagrant(TestCase):
    def setUp(self):
        self.run_local_command = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.tear_down.run_local_command'
        )

    def test_destroy_hypernode_vagrant_destroys_vagrant_in_specified_directory(self):
        destroy_hypernode_vagrant('/tmp/dir/12345')

        self.run_local_command.assert_called_once_with(
            'cd /tmp/dir/12345 && vagrant destroy -f',
            shell=True
        )
