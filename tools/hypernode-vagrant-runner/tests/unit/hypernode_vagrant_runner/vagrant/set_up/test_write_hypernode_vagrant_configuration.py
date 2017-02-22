from os.path import join
from tempfile import mkdtemp

from shutil import rmtree

from hypernode_vagrant_runner.settings import HYPERNODE_VAGRANT_CONFIGURATION, HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION, \
    HYPERNODE_VAGRANT_BOX_NAMES, HYPERNODE_VAGRANT_BOX_URLS, HYPERNODE_XENIAL_URL, HYPERNODE_XENIAL_BOX_NAME
from hypernode_vagrant_runner.vagrant.set_up import write_hypernode_vagrant_configuration
from tests.testcase import TestCase


class TestWriteHypernodeVagrantConfiguration(TestCase):
    def setUp(self):
        self.temp_dir = mkdtemp()
        self.temp_config_file = join(self.temp_dir, 'local.yml')

    def tearDown(self):
        rmtree(self.temp_dir, ignore_errors=True)

    def test_write_hypernode_vagrant_configuration_writes_configuration(self):
        write_hypernode_vagrant_configuration(self.temp_dir)

        with open(self.temp_config_file) as f:
            ret = f.read()
        expected_configuration = HYPERNODE_VAGRANT_CONFIGURATION.format(
            xdebug_enabled='false',
            php_version=HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION,
            box_name=HYPERNODE_VAGRANT_BOX_NAMES[
                HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION
            ],
            box_url=HYPERNODE_VAGRANT_BOX_URLS[
                HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION
            ],
            ubuntu_version='precise'
        )
        self.assertEqual(ret, expected_configuration)

    def test_write_hypernode_vagrant_configuration_writes_config_with_specified_php_version(self):
        write_hypernode_vagrant_configuration(self.temp_dir, php_version='5.5')

        with open(self.temp_config_file) as f:
            ret = f.read()
        expected_configuration = HYPERNODE_VAGRANT_CONFIGURATION.format(
            xdebug_enabled='false',
            php_version='5.5',
            box_name=HYPERNODE_VAGRANT_BOX_NAMES[
                '5.5'
            ],
            box_url=HYPERNODE_VAGRANT_BOX_URLS[
                '5.5'
            ],
            ubuntu_version='precise'
        )
        self.assertEqual(ret, expected_configuration)

    def test_write_hypernode_vagrant_configuration_writes_config_with_xdebug_enabled_if_specified(self):
        write_hypernode_vagrant_configuration(self.temp_dir, xdebug_enabled=True)

        with open(self.temp_config_file) as f:
            ret = f.read()
        expected_configuration = HYPERNODE_VAGRANT_CONFIGURATION.format(
            xdebug_enabled='true',
            php_version=HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION,
            box_name=HYPERNODE_VAGRANT_BOX_NAMES[
                HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION
            ],
            box_url=HYPERNODE_VAGRANT_BOX_URLS[
                HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION
            ],
            ubuntu_version='precise'
        )
        self.assertEqual(ret, expected_configuration)

    def test_write_hypernode_vagrant_configuration_writes_writes_config_with_xenial_image_if_specified(self):
        write_hypernode_vagrant_configuration(self.temp_dir, xenial=True)

        with open(self.temp_config_file) as f:
            ret = f.read()
        expected_configuration = HYPERNODE_VAGRANT_CONFIGURATION.format(
            xdebug_enabled='false',
            php_version=HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION,
            box_name=HYPERNODE_XENIAL_BOX_NAME,
            box_url=HYPERNODE_XENIAL_URL,
            ubuntu_version='xenial'
        )
        self.assertEqual(ret, expected_configuration)
