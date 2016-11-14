from hypernode_vagrant_runner.utils import try_sudo
from tests.testcase import TestCase


class TestTrySudo(TestCase):
    def setUp(self):
        self.geteuid = self.set_up_patch(
            'hypernode_vagrant_runner.utils.geteuid'
        )
        self.geteuid.return_value = 100  # Not root
        self.check_call = self.set_up_patch(
            'hypernode_vagrant_runner.utils.check_call'
        )

    def test_try_sudo_gets_euid(self):
        try_sudo()

        self.geteuid.assert_called_once_with()

    def test_try_sudo_tries_to_sudo_if_not_root(self):
        try_sudo()

        self.check_call.assert_called_once_with(
            "sudo echo 'yes we can sudo'",
            shell=True
        )

    def test_try_sudo_does_not_try_to_sudo_if_root(self):
        self.geteuid.return_value = 0

        try_sudo()

        self.assertFalse(self.check_call.called)
