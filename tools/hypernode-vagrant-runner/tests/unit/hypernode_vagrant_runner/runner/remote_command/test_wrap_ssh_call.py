from hypernode_vagrant_runner.runner.remote_command import wrap_ssh_call
from tests.testcase import TestCase


class TestWrapSSHCall(TestCase):
    def setUp(self):
        self.vagrant_ssh_config = {
            'HostName': '127.0.0.1',
            'Port': '2222',
            'IdentityFile': '/tmp/tmpZrTKrM/.vagrant/machines/hypernode/virtualbox/private_key'
        }

    def test_wrap_ssh_call_wraps_ssh_call(self):
        ret = wrap_ssh_call(self.vagrant_ssh_config, command_to_run='bash runtests.sh')

        self.assertEqual(
            ret,
            'ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null '
            '-i /tmp/tmpZrTKrM/.vagrant/machines/hypernode/virtualbox/private_key '
            '-p 2222 app@127.0.0.1 '
            '\'sh -c \'"\'"\'cd /data/web/public && bash runtests.sh\'"\'"\'\''
        )

    def test_wrap_ssh_call_wraps_ssh_call_as_specified_user(self):
        ret = wrap_ssh_call(
            self.vagrant_ssh_config, command_to_run='bash runtests.sh', ssh_user='root'
        )

        self.assertEqual(
            ret,
            'ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null '
            '-i /tmp/tmpZrTKrM/.vagrant/machines/hypernode/virtualbox/private_key '
            '-p 2222 root@127.0.0.1 '
            '\'sh -c \'"\'"\'cd /data/web/public && bash runtests.sh\'"\'"\'\''
        )

    def test_wrap_ssh_call_escapes_the_input_command(self):
        ret = wrap_ssh_call(
            self.vagrant_ssh_config, command_to_run='\';rm -rf /tmp/some_dir'
        )

        self.assertEqual(
            ret,
            'ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null '
            '-i /tmp/tmpZrTKrM/.vagrant/machines/hypernode/virtualbox/private_key '
            '-p 2222 app@127.0.0.1 '
            '\'sh -c \'"\'"\'cd /data/web/public && \'"\'"\';'
            'rm -rf /tmp/some_dir\'"\'"\'\''
        )
