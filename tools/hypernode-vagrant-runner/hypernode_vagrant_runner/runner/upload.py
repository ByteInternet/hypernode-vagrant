from logging import getLogger

from hypernode_vagrant_runner.settings import UPLOAD_PATH, HYPERNODE_VAGRANT_DEFAULT_USER
from hypernode_vagrant_runner.utils import run_local_command

log = getLogger(__name__)


def upload_project_to_vagrant(project_path, vagrant_info, ssh_user=HYPERNODE_VAGRANT_DEFAULT_USER):
    """
    Upload the project to the vagrant
    :param str project_path: The path on the host to upload
    :param dict vagrant_info: The vagrant ssh-config connection details
    :param str ssh_user: The SSH user to run the call as
    :return None:
    """
    log.info("Uploading project {} to /data/web/public on the vagrant.."
             "".format(project_path))
    upload_project_command = "rsync -q -avz --delete " \
                             "-e 'ssh -p {Port} -i {IdentityFile} " \
                             "-oStrictHostKeyChecking=no " \
                             "-oUserKnownHostsFile=/dev/null' " \
                             "{project_path}/* {user}@{HostName}:{upload_path}" \
                             "".format(user=ssh_user,
                                       project_path=project_path,
                                       upload_path=UPLOAD_PATH,
                                       **vagrant_info)
    run_local_command(upload_project_command, shell=True)
