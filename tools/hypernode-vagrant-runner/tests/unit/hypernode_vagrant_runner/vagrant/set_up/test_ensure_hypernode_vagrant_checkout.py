from hypernode_vagrant_runner.settings import HYPERNODE_VAGRANT_REPOSITORY
from hypernode_vagrant_runner.vagrant.set_up import ensure_hypernode_vagrant_checkout
from tests.testcase import TestCase


class TestEnsureHypernodeVagrantCheckout(TestCase):
    def setUp(self):
        self.is_hypernode_vagrant_directory = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.set_up.is_hypernode_vagrant_directory'
        )
        self.is_hypernode_vagrant_directory.return_value = False
        self.run_local_command = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.set_up.run_local_command'
        )

    def test_ensure_hypernode_vagrant_checkout_checks_if_directory_is_hypernode_vagrant(self):
        ensure_hypernode_vagrant_checkout('/tmp/tmpdir1234')

        self.is_hypernode_vagrant_directory.assert_called_once_with(
            '/tmp/tmpdir1234'
        )

    def test_ensure_hypernode_vagrant_checkout_does_nothing_when_existing_vagrant_file_found(self):
        self.is_hypernode_vagrant_directory.return_value = True

        ensure_hypernode_vagrant_checkout('/tmp/tmpdir1234')

        self.assertFalse(self.run_local_command.called)

    def test_ensure_hypernode_vagrant_checkout_clones_hypernode_vagrant_to_directory(self):
        ensure_hypernode_vagrant_checkout('/tmp/tmpdir1234')

        self.run_local_command.assert_called_once_with(
            ['git', 'clone', HYPERNODE_VAGRANT_REPOSITORY, '/tmp/tmpdir1234']
        )
