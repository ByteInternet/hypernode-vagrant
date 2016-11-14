from hypernode_vagrant_runner.vagrant import remove_hypernode_vagrant
from tests.testcase import TestCase


class TestRemoveHypernodeVagrant(TestCase):
    def setUp(self):
        self.rmtree = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.tear_down.rmtree'
        )

    def test_remove_hypernode_vagrant_force_removes_checkout_directory(self):
        remove_hypernode_vagrant('/tmp/dir/12345')

        self.rmtree.assert_called_once_with(
            '/tmp/dir/12345', ignore_errors=True
        )
