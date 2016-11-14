from logging import getLogger, DEBUG, INFO, StreamHandler
from sys import stdout


def setup_logging(debug=False):
    """
    Set up the logging for hypernode_vagrant_runner
    :param bool debug: Log DEBUG level to console (INFO is default)
    :return obj logger: The logger object
    """
    logger = getLogger('hypernode_vagrant_runner')
    logger.setLevel(DEBUG if debug else INFO)
    console_handler = StreamHandler(stdout)
    logger.addHandler(console_handler)
    return logger
