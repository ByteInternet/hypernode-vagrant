from hypernode_vagrant_runner.vagrant.set_up import is_hypernode_vagrant_directory
from tests.testcase import TestCase


class TestIsHypernodeVagrantDirectory(TestCase):
    def setUp(self):
        self.isfile = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.set_up.isfile'
        )
        self.isfile.return_value = True

    def test_is_hypernode_vagrant_directory_checks_if_vagrantfile_exists_in_directory(self):
        is_hypernode_vagrant_directory('/tmp/tmpdir1234')

        self.isfile.assert_called_once_with(
            '/tmp/tmpdir1234/Vagrantfile'
        )

    def test_is_hypernode_vagrant_directory_returns_true_if_vagrantfile_exists_already(self):
        ret = is_hypernode_vagrant_directory('/tmp/tmpdir1234')

        self.assertTrue(ret)

    def test_is_hypernode_vagrant_directory_returns_false_if_no_vagrantfile_yet(self):
        self.isfile.return_value = False

        ret = is_hypernode_vagrant_directory('/tmp/tmpdir1234')

        self.assertFalse(ret)
