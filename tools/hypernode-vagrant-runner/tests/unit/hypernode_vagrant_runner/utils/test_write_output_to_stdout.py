from mock import Mock

from hypernode_vagrant_runner.utils import write_output_to_stdout
from tests.testcase import TestCase


class TestWriteOutputToStdout(TestCase):
    def setUp(self):
        self.stdout = self.set_up_patch(
            'hypernode_vagrant_runner.utils.stdout'
        )
        self.output = Mock()

    def test_write_output_to_stdout_attempts_to_write_to_buffer(self):
        write_output_to_stdout(self.output)

        self.stdout.buffer.write.assert_called_once_with(self.output)

    def test_write_output_to_stdout_does_not_write_directly_to_stdout(self):
        write_output_to_stdout(self.output)

        self.assertFalse(self.stdout.write.called)

    def test_write_output_to_stdout_writes_directly_to_stdout_if_can_not_write_to_buffer(self):
        # In Python 2 stdout.buffer does not exists, so we need to write
        # the output (which is not a bytestring in python 2) directly
        # to sys.stdout
        self.stdout.buffer.write.side_effect = AttributeError

        write_output_to_stdout(self.output)

        self.stdout.write.assert_called_once_with(self.output)
