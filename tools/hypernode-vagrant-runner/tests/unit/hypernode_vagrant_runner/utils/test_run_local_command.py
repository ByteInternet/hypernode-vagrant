from hypernode_vagrant_runner.utils import run_local_command
from tests.testcase import TestCase


class TestRunLocalCommand(TestCase):
    def setUp(self):
        self.check_output = self.set_up_patch(
            'hypernode_vagrant_runner.utils.check_output'
        )
        self.is_python_3 = self.set_up_patch(
            'hypernode_vagrant_runner.utils.is_python_3'
        )
        self.is_python_3.return_value = True
        self.write_output_to_stdout = self.set_up_patch(
            'hypernode_vagrant_runner.utils.write_output_to_stdout'
        )

    def test_run_local_command_checks_output_of_specified_command(self):
        run_local_command(['echo', '1'])

        self.check_output.assert_called_once_with(
            ['echo', '1'], shell=False
        )

    def test_run_local_command_checks_output_of_shell_command(self):
        run_local_command('echo 1 | xargs', shell=True)

        self.check_output.assert_called_once_with(
            'echo 1 | xargs', shell=True
        )

    def test_run_local_command_writes_output_to_stdout(self):
        run_local_command(['echo', '1'])

        self.write_output_to_stdout.assert_called_once_with(
            self.check_output.return_value
        )

    def test_run_local_command_decodes_output_if_python_3(self):
        ret = run_local_command(['echo', '1'])

        self.check_output.return_value.decode.assert_called_once_with('utf-8')
        self.assertEqual(ret, self.check_output.return_value.decode.return_value)

    def test_run_local_command_does_not_decode_output_if_python_2_because_it_is_already_a_string(self):
        self.is_python_3.return_value = False

        ret = run_local_command(['echo', '1'])

        self.assertFalse(self.check_output.return_value.decode.called)
        self.assertEqual(ret, self.check_output.return_value)
