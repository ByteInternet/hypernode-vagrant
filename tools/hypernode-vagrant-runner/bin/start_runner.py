#!/usr/bin/env python
from hypernode_vagrant_runner.commands import start_runner

if __name__ == '__main__':
    start_runner()
else:
    raise RuntimeError("This script is an entry point and can not be imported")
