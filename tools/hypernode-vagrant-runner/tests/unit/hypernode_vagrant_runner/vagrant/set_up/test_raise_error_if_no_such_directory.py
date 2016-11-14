from hypernode_vagrant_runner.vagrant.set_up import raise_error_if_no_such_directory
from tests.testcase import TestCase


class TestRaiseErrorIfNoSuchDirectory(TestCase):
    def setUp(self):
        self.isdir = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.set_up.isdir'
        )
        self.isdir.return_value = True

    def test_raise_error_if_no_such_directory_raises_runtime_error_if_no_such_directory(self):
        self.isdir.return_value = False

        with self.assertRaises(RuntimeError):
            raise_error_if_no_such_directory('/tmp/tmpdir12345')

    def test_raise_error_if_no_such_directory_does_not_raise_error_if_directory_exists(self):
        # Does not raise RuntimeError
        self.assertIsNone(raise_error_if_no_such_directory('/tmp/tmpdir12345'))
