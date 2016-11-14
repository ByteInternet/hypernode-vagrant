from mock import Mock

from hypernode_vagrant_runner.commands import parse_arguments
from tests.testcase import TestCase


class TestParseArguments(TestCase):
    def setUp(self):
        self.parser = Mock()
        self.setup_logging = self.set_up_patch('hypernode_vagrant_runner.commands.setup_logging')

    def test_parse_arguments_adds_verbose_arguments(self):
        parse_arguments(self.parser)

        self.parser.add_argument.assert_called_once_with('--verbose', '-v', action='store_true')

    def test_parse_arguments_parses_arguments(self):
        parse_arguments(self.parser)

        self.parser.parse_args.assert_called_once_with()

    def test_parse_arguments_sets_up_logging(self):
        parse_arguments(self.parser)

        self.setup_logging.assert_called_once_with(debug=self.parser.parse_args.return_value.verbose)

    def test_parse_arguments_returns_arguments(self):
        ret = parse_arguments(self.parser)

        self.assertEqual(ret, self.parser.parse_args.return_value)

