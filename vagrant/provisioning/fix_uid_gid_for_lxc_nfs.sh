#!/bin/bash

# this script fixes the uid and gid for the app user so that it has the right permissions to 
# interact with an nfs share if the box is lxc
# see: https://github.com/fgrehm/vagrant-lxc/issues/151

set -e

while getopts "u:g:" opt; do
    case "$opt" in
        u)
            target_uid="$OPTARG" ;;
	g)
	    target_gid="$OPTARG" ;;
    esac
done

src_uid="$(id -u app)"
src_gid="$(id -g app)"


test "$src_uid" = "$target_uid" && test "$src_gid" = "$target_gid" && exit 0

sed -E "s/(app:.:)$src_uid:$src_gid:/\\1$target_uid:$target_gid:/g" --in-place /etc/passwd
sed -E "s/(app:.:)$src_gid:/\\1$target_gid:/g" --in-place /etc/group

find / -uid "$src_uid" 2> /dev/null | grep --invert-match -E "^(/sys|/proc)" | xargs chown "$target_uid"
find / -gid "$src_gid" 2> /dev/null | grep --invert-match -E "^(/sys|/proc)" | xargs chgrp "$target_gid"
