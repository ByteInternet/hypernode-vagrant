from mock import call
from subprocess import CalledProcessError

from hypernode_vagrant_runner.utils import run_local_command, is_python_3
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

    def test_run_local_command_also_writes_stderr_and_stdout_to_stdout_in_case_of_nonzero_exit_in_python3(self):
        if is_python_3():
            self.check_output.side_effect = CalledProcessError(
                1, cmd='echo 1', output='stdout', stderr='stderr'
            )

            with self.assertRaises(CalledProcessError):
                run_local_command(['echo', '1'])

            expected_calls = [
                call('stdout'), call('stderr')
            ]
            # For loop instead of assertEqual(s) or assertCountEqual(s) because
            # that is both Python 2 and 3 compatible.
            for expected_call in expected_calls:
                self.assertIn(expected_call, self.write_output_to_stdout.mock_calls)

    def test_run_local_command_also_writes_stdout_to_stdout_in_case_of_nonzero_exit_in_python2(self):
        if not is_python_3():
            self.check_output.side_effect = CalledProcessError(
                1, cmd='echo 1', output='stdout',
                # No stderr in CalledProcessError in Python 2
            )

            with self.assertRaises(CalledProcessError):
                run_local_command(['echo', '1'])

            self.write_output_to_stdout.assert_called_once_with('stdout')

    def test_run_local_command_decodes_output_if_python_3(self):
        ret = run_local_command(['echo', '1'])

        self.check_output.return_value.decode.assert_called_once_with('utf-8')
        self.assertEqual(ret, self.check_output.return_value.decode.return_value)

    def test_run_local_command_does_not_decode_output_if_python_2_because_it_is_already_a_string(self):
        self.is_python_3.return_value = False

        ret = run_local_command(['echo', '1'])

        self.assertFalse(self.check_output.return_value.decode.called)
        self.assertEqual(ret, self.check_output.return_value)
