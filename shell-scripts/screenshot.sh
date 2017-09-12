#!/bin/bash
#
# TTY: num of tty {1, 2, 3, ...}
# Note: use root run

TTY=$1
cat "/dev/vcs${TTY}" | sed "s:.\{`stty -F /dev/tty${TTY} -a |grep columns |awk '{print $7}' |sed "s:;::"`\}:&\n:g" | convert -negate -font Courier label:@- screenshot.png
