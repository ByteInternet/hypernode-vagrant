from hypernode_vagrant_runner.settings import HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION
from hypernode_vagrant_runner.vagrant.set_up import start_hypernode_vagrant
from tests.testcase import TestCase


class TestStartHypernodeVagrant(TestCase):
    def setUp(self):
        self.write_hypernode_vagrant_configuration = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.set_up.write_hypernode_vagrant_configuration'
        )
        self.run_vagrant_up = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.set_up.run_vagrant_up'
        )

    def test_start_hypernode_vagrant_writes_Hypernode_vagrant_configuration(self):
        start_hypernode_vagrant('/tmp/tmpdir1234')

        self.write_hypernode_vagrant_configuration.assert_called_once_with(
            '/tmp/tmpdir1234', php_version=HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION
        )

    def test_start_hypernode_vagrant_writes_hypernode_vagrant_configuration_for_specified_php_version(self):
        start_hypernode_vagrant('/tmp/tmpdir1234', php_version='5.5')

        self.write_hypernode_vagrant_configuration.assert_called_once_with(
            '/tmp/tmpdir1234', php_version='5.5'
        )

    def test_start_hypernode_vagrant_runs_vagrant_up(self):
        start_hypernode_vagrant('/tmp/tmpdir1234')

        self.run_vagrant_up.assert_called_once_with(
            '/tmp/tmpdir1234'
        )
