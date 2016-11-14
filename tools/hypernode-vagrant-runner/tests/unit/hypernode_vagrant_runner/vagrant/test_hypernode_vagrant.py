from hypernode_vagrant_runner.settings import HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION
from hypernode_vagrant_runner.vagrant import hypernode_vagrant
from tests.testcase import TestCase


class TestHypernodeVagrant(TestCase):
    def setUp(self):
        self.create_hypernode_vagrant = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.create_hypernode_vagrant'
        )
        self.get_networking_information_from_vagrant = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.get_networking_information_from_vagrant'
        )
        self.destroy_hypernode_vagrant = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.destroy_hypernode_vagrant'
        )
        self.remove_hypernode_vagrant = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.remove_hypernode_vagrant'
        )

    def test_hypernode_vagrant_creates_hypernode_vagrant_before_context(self):
        with hypernode_vagrant():
            self.create_hypernode_vagrant.assert_called_once_with(
                directory=None,
                php_version=HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION
            )

    def test_hypernode_vagrant_creates_hypernode_vagrant_using_specified_checkout(self):
        with hypernode_vagrant(
                directory='/your/already/checked/out/hypernode-vagrant'
        ):
            self.create_hypernode_vagrant.assert_called_once_with(
                directory='/your/already/checked/out/hypernode-vagrant',
                php_version=HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION
            )

    def test_hypernode_vagrant_creates_hypernode_vagrant_of_specified_php_version(self):
        with hypernode_vagrant(php_version='7.0'):
            self.create_hypernode_vagrant.assert_called_once_with(
                directory=None,
                php_version='7.0'
            )

    def test_hypernode_vagrant_destroys_hypernode_vagrant_after_context(self):
        with hypernode_vagrant():
            self.assertFalse(self.destroy_hypernode_vagrant.called)
        self.destroy_hypernode_vagrant.assert_called_once_with(
            self.create_hypernode_vagrant.return_value
        )

    def test_hypernode_vagrant_removes_hypernode_vagrant_after_context(self):
        with hypernode_vagrant():
            self.assertFalse(self.remove_hypernode_vagrant.called)
        self.remove_hypernode_vagrant.assert_called_once_with(
            self.create_hypernode_vagrant.return_value
        )

    def test_hypernode_vagrant_does_not_destroy_hypernode_vagrant_if_pre_existing_directory_used(self):
        with hypernode_vagrant(directory='/tmp/some/directory'):
            pass
        self.assertFalse(self.destroy_hypernode_vagrant.called)

    def test_hypernode_vagrant_does_not_remove_hypernode_vagrant_if_pre_existing_directory_used(self):
        with hypernode_vagrant(directory='/tmp/some/directory'):
            pass
        self.assertFalse(self.remove_hypernode_vagrant.called)

    def test_hypernode_vagrant_yields_vagrant_networking_information(self):
        with hypernode_vagrant() as information:
            self.assertEqual(
                information, self.get_networking_information_from_vagrant.return_value
            )

    def test_hypernode_vagrant_gets_networking_information_from_created_vagrant(self):
        with hypernode_vagrant():
            self.get_networking_information_from_vagrant.assert_called_once_with(
                self.create_hypernode_vagrant.return_value
            )
