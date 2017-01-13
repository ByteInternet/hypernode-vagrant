from hypernode_vagrant_runner.vagrant.set_up import ensure_directory
from tests.testcase import TestCase


class TestEnsureDirectory(TestCase):
    def setUp(self):
        self.isdir = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.set_up.isdir'
        )
        self.isdir.return_value = True
        self.makedirs = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.set_up.makedirs'
        )

    def test_ensure_directory_creates_directory_if_no_such_directory(self):
        self.isdir.return_value = False

        ensure_directory('/tmp/tmpdir12345')

        self.makedirs.assert_called_once_with('/tmp/tmpdir12345')

    def test_ensure_directory_does_not_create_directory_if_directory_exists(self):
        ensure_directory('/tmp/tmpdir12345')

        self.assertFalse(self.makedirs.called)
