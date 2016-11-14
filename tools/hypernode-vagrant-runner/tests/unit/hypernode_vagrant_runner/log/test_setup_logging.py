from logging import INFO, DEBUG
from sys import stdout

from hypernode_vagrant_runner.log import setup_logging
from tests.testcase import TestCase


class TestSetupLogging(TestCase):
    def setUp(self):
        self.get_logger = self.set_up_patch('hypernode_vagrant_runner.log.getLogger')
        self.stream_handler = self.set_up_patch('hypernode_vagrant_runner.log.StreamHandler')

    def test_setup_logging_gets_logger(self):
        setup_logging()

        self.get_logger.assert_called_once_with('hypernode_vagrant_runner')

    def test_setup_logging_sets_logging_level_to_info_by_default(self):
        setup_logging()

        self.get_logger.return_value.setLevel.assert_called_once_with(INFO)

    def test_setup_logging_sets_logging_level_to_debug_if_debug_is_specified(self):
        setup_logging(debug=True)

        self.get_logger.return_value.setLevel.assert_called_once_with(DEBUG)

    def test_setup_logging_instantiates_stream_handler_with_stdout(self):
        setup_logging(debug=True)

        self.stream_handler.assert_called_once_with(stdout)

    def test_setup_logging_adds_console_handler_to_logger(self):
        setup_logging(debug=True)

        self.get_logger.return_value.addHandler.assert_called_once_with(
            self.stream_handler.return_value
        )

    def test_setup_logging_returns_logger(self):
        ret = setup_logging(debug=True)

        self.assertEqual(ret, self.get_logger.return_value)

