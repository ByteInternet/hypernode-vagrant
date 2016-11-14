from hypernode_vagrant_runner.settings import HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION
from hypernode_vagrant_runner.vagrant import create_hypernode_vagrant
from tests.testcase import TestCase


class TestCreateHypernodeVagrant(TestCase):
    def setUp(self):
        self.try_sudo = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.set_up.try_sudo'
        )
        self.ensure_directory_for_checkout = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.set_up.ensure_directory_for_checkout'
        )
        self.ensure_hypernode_vagrant_checkout = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.set_up.ensure_hypernode_vagrant_checkout'
        )
        self.ensure_required_plugins_are_installed = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.set_up.ensure_required_plugins_are_installed'
        )
        self.start_hypernode_vagrant = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.set_up.start_hypernode_vagrant'
        )

    def test_create_hypernode_vagrant_tries_sudo(self):
        create_hypernode_vagrant()

        self.try_sudo.assert_called_once_with()

    def test_create_hypernode_vagrant_ensures_directory_for_checkout(self):
        create_hypernode_vagrant()

        self.ensure_directory_for_checkout.assert_called_once_with(
            directory=None
        )

    def test_create_hypernode_vagrant_uses_specified_pre_existing_directory_if_specified(self):
        create_hypernode_vagrant(directory='/tmp/some/pre/existing/directory')

        self.ensure_directory_for_checkout.assert_called_once_with(
            directory='/tmp/some/pre/existing/directory'
        )

    def test_create_hypernode_vagrant_ensures_hypernode_vagrant_checkout(self):
        create_hypernode_vagrant()

        self.ensure_hypernode_vagrant_checkout.assert_called_once_with(
            directory=self.ensure_directory_for_checkout.return_value
        )

    def test_create_hypernode_vagrant_ensures_required_plugins_are_installed(self):
        create_hypernode_vagrant()

        self.ensure_required_plugins_are_installed.assert_called_once_with()

    def test_create_hypernode_vagrant_starts_hypernode_vagrant_in_ensured_path(self):
        create_hypernode_vagrant()

        self.start_hypernode_vagrant.assert_called_once_with(
            self.ensure_directory_for_checkout.return_value,
            php_version=HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION
        )

    def test_create_hypernode_vagrant_starts_hypernode_vagrant_with_specified_php_version(self):
        create_hypernode_vagrant(php_version='5.5')

        self.start_hypernode_vagrant.assert_called_once_with(
            self.ensure_directory_for_checkout.return_value,
            php_version='5.5'
        )

    def test_create_hypernode_vagrant_returns_ensured_directory(self):
        ret = create_hypernode_vagrant()

        self.assertEqual(ret, self.ensure_directory_for_checkout.return_value)
