# hypernode-vagrant-runner

Run your project inside a [hypernode-vagrant](http://github.com/ByteInternet/hypernode-vagrant) Virtual Machine by adding one file to your project.

## What is this?

This project is a program that automatically creates a hypernode-vagrant checkout in a temporary directory, boots the VM, uploads the specified project and runs a command in the uploaded directory and then cleans it all up again after the tests have finished. The default configuration is a loop where you can alter files on the host, press ENTER in the test-prompt and have the program automatically sync the files and run the tests again.  

Why run tests in a Vagrant? There are many reasons. One is that you completely eliminate 'state' by throwing away the test environment. For example, if you happened to have installed a package or made a change on your host system that is not in a real Hypernode, then your code might work locally but not in production. Same goes for changes between revisions.  There could be slightly different PHP version, etc.  A second reason is that the host system does not have to have the requirements installed to run the tests because they can be contained to the Vagrant guest. 

I personally mostly develop in Python so not having to worry about having composer or whatever web package du jour installed locally saves me some time in not having to first explore an ecosystem that I am not too familiar with before making code changes. 

Only for Linux and Mac

## Usage

The help menu:
```bash
PYTHONPATH=. ./bin/start_runner.py --help
```

Boot a hypernode-vagrant and get an SSH shell
```bash
PYTHONPATH=. ./bin/start_runner.py
```

Upload a project to a new hypernode-vagrant and get a shell
```bash
PYTHONPATH=. ./bin/start_runner.py --project-dir=~/code/projects/hypernode-magerun
```

Upload a project to a new hypernode-vagrant and run a test command
```bash
PYTHONPATH=. ./bin/start_runner.py --project-dir=~/code/projects/hypernode-magerun --command-to-run='bash runtests.sh'
```

This gets you a test-prompt where you can change things in your project and then upload and run the tests again, or drop into a shell and change things in the Vagrant before running the tests again.
```bash
OK, but incomplete, skipped, or risky tests!
Tests: 21, Assertions: 4, Skipped: 19.
Looks like everything is OK

Press enter to run the run the command again.
S + Enter to get a shell.
CTRL + C to stop the loop.
> 
```

Getting a shell from the test-prompt
```bash
> s
Getting remote shell on 127.0.0.1:2222
Warning: Permanently added '[127.0.0.1]:2222' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 12.04.3 LTS (GNU/Linux 3.13.0-100-generic x86_64)

 * Documentation:  https://help.ubuntu.com/
New release '14.04.5 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

Welcome to your Vagrant-built virtual machine.
No mail.
Last login: Sun Nov 13 20:18:24 2016 from 10.0.2.2
app@358481-tmpj2b2jvo8-magweb-vgr:~$ 
# Type 'exit' to return to the test-prompt
```

Run the tests again by pressing ENTER
```bash
> 
Uploading project /home/vdloo/code/projects/hypernode-magerun to /data/web/public on the vagrant..
Warning: Permanently added '[127.0.0.1]:2222' (ECDSA) to the list of known hosts.
sending incremental file list
composer.json
...
```

Press CTRL + C to stop the loop and to destroy and clean up the Vagrant
```bash
> Interrupt received. Terminating loop.
Destroying Vagrant
[sudo] password for vdloo: 
==> hypernode: vagrant.actions.vm.halt.force
==> hypernode: Destroying VM and associated drives...
==> hypernode: Updating /etc/hosts file on active guest machines...
==> hypernode: Updating /etc/hosts file on host machine (password may be required)...
Cleaning up temporary hypernode-vagrant directory
```

## Example

Run the hypernode-vagrant-runner unit tests in a hypernode-vagrant started by the hypernode-vagrant-runner
```bash
git clone https://github.com/ByteInternet/hypernode-vagrant
cd hypernode-vagrant/tools/hypernode-vagrant-runner
chmod +x example_runtests.sh
./example_runtests.sh
```

## Adding hypernode-vagrant-runner to your project

Create a file (runtests.sh) with the following contents. Adjust the TEST_COMMAND and TEST_USER var to reflect your project.
```bash
#!/usr/bin/env bash
set -e

TEST_COMMAND="vendor/bin/phpunit --debug --stop-on-error --stop-on-failure"
TEST_USER='app'

HYPERNODE_VAGRANT_RUNNER_REPO="https://github.com/ByteInternet/hypernode-vagrant"
HYPERNODE_VAGRANT_RUNNER_DIR='/tmp/hypernode-vagrant-runner'
PROJECT_DIRECTORY="$(dirname "$(readlink -f "$0")")"


if [ -d "$HYPERNODE_VAGRANT_RUNNER_DIR" ]; then
    echo "Ensuring the hypernode-vagrant-runner is the latest version in $HYPERNODE_VAGRANT_RUNNER_DIR"
    cd "$HYPERNODE_VAGRANT_RUNNER_DIR"
    git clean -xfd
    git pull origin master || /bin/true
    git reset --hard origin/master
    cd -
else
    echo "Creating a new checkout of hypernode-vagrant-runner in $HYPERNODE_VAGRANT_RUNNER_DIR"
    git clone $HYPERNODE_VAGRANT_RUNNER_REPO $HYPERNODE_VAGRANT_RUNNER_DIR
fi;

chmod +x ${HYPERNODE_VAGRANT_RUNNER_DIR}/tools/hypernode-vagrant-runner/bin/start_runner.py
PYTHONPATH=${HYPERNODE_VAGRANT_RUNNER_DIR}/tools/hypernode-vagrant-runner \
    ${HYPERNODE_VAGRANT_RUNNER_DIR}/tools/hypernode-vagrant-runner/bin/start_runner.py \
    --project-path="$PROJECT_DIRECTORY" \
    --command-to-run="$TEST_COMMAND" \
    --user="$TEST_USER" \
    "$@"  # All other arguments. So you can run ./runtests.sh -1 for example
```

Make sure the script is executable:
```bash
chmod +x runtests.sh
```

You can now run loop the tests of your project in an ephemeral hypernode-vagrant by running the following command:
```bash
./runtest.sh
...
Time: 73 ms, Memory: 6.00MB

OK, but incomplete, skipped, or risky tests!
Tests: 21, Assertions: 4, Skipped: 19.
Looks like everything is OK

Press enter to run the run the command again.
S + Enter to get a shell.
CTRL + C to stop the loop.
>
```

You can also just run it once and immediately destroy the Vagrant.
If you want to run your tests in Jenkins this is probably what you are looking for.
```bash
./runtests.sh -1
```

## Development

Note: This project has no python dependencies except for a Python (2 or 3) interpreter and the tooling to run the VM (Vagrant, Virtualbox, git, rsync). The reasoning behind that is that the benefit of having not to worry about libraries outweighs the cost of having some extra code that could be imported from modules like six. The goal is to make it easy to drop the runtests.sh script somewhere to combine hypernode-vagrant with projects without having to rewrite the same shell scripts to get the Vagrant set up every time.

Running the unit tests
```bash
# Run the tests
./runtests.sh -1

# Run the tests in a loop (CTRL + C to stop)
./runtests.sh
```
