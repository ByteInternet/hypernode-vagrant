from hypernode_vagrant_runner.runner import upload_project_to_vagrant
from tests.testcase import TestCase


class TestUploadProjectToVagrant(TestCase):
    def setUp(self):
        self.run_local_command = self.set_up_patch(
            'hypernode_vagrant_runner.runner.upload.run_local_command'
        )
        self.vagrant_ssh_config = {
            'HostName': '127.0.0.1',
            'Port': '2222',
            'IdentityFile': '/tmp/tmpZrTKrM/.vagrant/machines/hypernode/virtualbox/private_key'
        }

    def test_upload_project_to_vagrant_runs_upload_in_the_shell(self):
        upload_project_to_vagrant(
            project_path='/home/some_user/code/projects/hypernode_vagrant_runner',
            vagrant_info=self.vagrant_ssh_config
        )

        expected_command = "rsync -avz --delete -e " \
                           "'ssh -p 2222 " \
                           "-i /tmp/tmpZrTKrM/.vagrant/machines/hypernode/virtualbox/private_key " \
                           "-oStrictHostKeyChecking=no " \
                           "-oUserKnownHostsFile=/dev/null' " \
                           "/home/some_user/code/projects/hypernode_vagrant_runner/* " \
                           "root@127.0.0.1:/data/web/public"
        self.run_local_command.assert_called_once_with(
            expected_command, shell=True
        )

        self.assertIn(
            '--delete', expected_command,
            "--delete not found in expected rsync command. "
            "Without this flag changes on the host might be synced "
            "incomplete because removed files are not removed from the guest"
        )
        self.assertIn(
            '-p 2222', expected_command,
            'The rsync command did not contain the specified nonstandard port'
        )
        self.assertIn(
            '/data/web/public', expected_command,
            'The destination path was not in the rsync command. If the '
            'files are not uploaded to the webroot they will not be accessible '
            'over the webserver with the default configuration.'
        )