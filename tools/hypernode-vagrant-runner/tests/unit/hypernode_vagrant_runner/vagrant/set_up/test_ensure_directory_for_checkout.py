from hypernode_vagrant_runner.vagrant.set_up import ensure_directory_for_checkout
from tests.testcase import TestCase


class TestEnsureDirectoryForCheckout(TestCase):
    def setUp(self):
        self.ensure_directory = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.set_up.ensure_directory'
        )
        self.mkdtemp = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.set_up.mkdtemp'
        )

    def test_ensure_directory_for_checkout_creates_directory_if_needed_when_dir_specified(self):
        ensure_directory_for_checkout(directory='/tmp/dir/12345')

        self.ensure_directory.assert_called_once_with(
            '/tmp/dir/12345'
        )

    def test_ensure_directory_for_checkout_does_not_raise_error_if_no_such_dir_if_no_dir_specified(self):
        ensure_directory_for_checkout()

        self.assertFalse(self.ensure_directory.called)

    def test_ensure_directory_for_checkout_returns_directory(self):
        ret = ensure_directory_for_checkout(directory='/tmp/dir/12345')

        self.assertEqual(ret, '/tmp/dir/12345')

    def test_ensure_directory_for_checkout_does_not_create_temp_dir_if_dir_specified(self):
        ensure_directory_for_checkout(directory='/tmp/dir/12345')

        self.assertFalse(self.mkdtemp.called)

    def test_ensure_directory_for_checkout_makes_temp_dir_if_no_dir_specified(self):
        ensure_directory_for_checkout()

        self.mkdtemp.assert_called_once_with()

    def test_ensure_directory_for_checkout_returns_new_temporary_directory_if_no_dir_specified(self):
        ret = ensure_directory_for_checkout()

        self.assertEqual(ret, self.mkdtemp.return_value)
