from os.path import join
from tempfile import mkdtemp

from shutil import rmtree

from hypernode_vagrant_runner.settings import HYPERNODE_VAGRANT_CONFIGURATION, HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION, \
    HYPERNODE_VAGRANT_BOX_NAMES, HYPERNODE_VAGRANT_BOX_URLS
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
            php_version=HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION,
            box_name=HYPERNODE_VAGRANT_BOX_NAMES[
                HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION
            ],
            box_url=HYPERNODE_VAGRANT_BOX_URLS[
                HYPERNODE_VAGRANT_DEFAULT_PHP_VERSION
            ]
        )
        self.assertEqual(ret, expected_configuration)

    def test_write_hypernode_vagrant_configuration_writes_config_with_specified_php_version(self):
        write_hypernode_vagrant_configuration(self.temp_dir, php_version='5.5')

        with open(self.temp_config_file) as f:
            ret = f.read()
        expected_configuration = HYPERNODE_VAGRANT_CONFIGURATION.format(
                php_version='5.5',
                box_name=HYPERNODE_VAGRANT_BOX_NAMES[
                    '5.5'
                ],
                box_url=HYPERNODE_VAGRANT_BOX_URLS[
                    '5.5'
                ]
        )
        self.assertEqual(ret, expected_configuration)
