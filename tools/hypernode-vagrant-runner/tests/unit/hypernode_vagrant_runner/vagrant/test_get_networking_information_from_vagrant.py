from mock import call

from hypernode_vagrant_runner.vagrant import get_networking_information_from_vagrant
from tests.testcase import TestCase


class TestGetNetworkingInformationFromVagrant(TestCase):
    def setUp(self):
        self.run_local_command = self.set_up_patch(
            'hypernode_vagrant_runner.vagrant.run_local_command'
        )

    def test_get_networking_information_from_vagrant_queries_vagrant_ssh_config(self):
        get_networking_information_from_vagrant('/tmp/some/vagrant/checkout')

        expected_calls = [
            call(
                "cd /tmp/some/vagrant/checkout && vagrant ssh-config "
                "| grep HostName | awk '{print $NF}'",
                shell=True
            ),
            call(
                "cd /tmp/some/vagrant/checkout && vagrant ssh-config "
                "| grep Port | awk '{print $NF}'",
                shell=True
            ),
            call(
                "cd /tmp/some/vagrant/checkout && vagrant ssh-config "
                "| grep IdentityFile | awk '{print $NF}'",
                shell=True
            ),
        ]
        for expected_call in expected_calls:
            self.assertIn(expected_call, self.run_local_command.mock_calls)

    def test_get_networking_information_from_vagrant_queries_returns_dict(self):
        ret = get_networking_information_from_vagrant(
            '/tmp/some/vagrant/checkout'
        )

        expected_information = {
            'HostName': self.run_local_command.return_value.strip.return_value,
            'Port': self.run_local_command.return_value.strip.return_value,
            'IdentityFile': self.run_local_command.return_value.strip.return_value,
        }
        self.assertEqual(ret, expected_information)
