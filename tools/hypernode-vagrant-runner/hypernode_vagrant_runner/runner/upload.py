from logging import getLogger

from hypernode_vagrant_runner.settings import UPLOAD_PATH
from hypernode_vagrant_runner.utils import run_local_command

log = getLogger(__name__)


def upload_project_to_vagrant(project_path, vagrant_info):
    """
    Upload the project to the vagrant
    :param str project_path: The path on the host to upload
    :param dict vagrant_info: The vagrant ssh-config connection details
    :return None:
    """
    log.info("Uploading project {} to /data/web/public on the vagrant.."
             "".format(project_path))
    upload_project_command = "rsync -avz --delete " \
                             "-e 'ssh -p {Port} -i {IdentityFile} " \
                             "-oStrictHostKeyChecking=no " \
                             "-oUserKnownHostsFile=/dev/null' " \
                             "{project_path}/* root@{HostName}:{upload_path}" \
                             "".format(project_path=project_path,
                                       upload_path=UPLOAD_PATH,
                                       **vagrant_info)
    run_local_command(upload_project_command, shell=True)
