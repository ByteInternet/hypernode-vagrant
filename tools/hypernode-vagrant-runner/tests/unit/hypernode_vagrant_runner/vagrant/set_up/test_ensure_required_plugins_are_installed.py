from mock import call

from hypernode_vagrant_runner.settings import REQUIRED_VAGRANT_PLUGINS
from hypernode_vagrant_runner.vagrant.set_up import ensure_required_plugins_are_installed
from tests.testcase import TestCase


class TestEnsureRequiredPluginsAreInstalled(TestCase):
    def setUp(self):
        self.run_local_command = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.set_up.run_local_command'
        )

    def test_ensure_required_plugins_are_installed(self):
        ensure_required_plugins_are_installed()

        expected_calls = [
            call(
                "vagrant plugin list | grep {plugin} || vagrant plugin install {plugin}"
                "".format(plugin=plugin),
                shell=True
            ) for plugin in REQUIRED_VAGRANT_PLUGINS
        ]

        # For loop instead of assertEqual(s) or assertCountEqual(s) because
        # that is both Python 2 and 3 compatible.
        for expected_call in expected_calls:
            self.assertIn(expected_call, self.run_local_command.mock_calls)
