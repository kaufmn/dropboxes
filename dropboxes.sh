#!/bin/bash
dropboxes="dropbox_home dropbox_work"
for dropbox in $dropboxes
do
    HOME="/home/$USER"
    if ! [ -d "$HOME/$dropbox" ]
    then
        mkdir "$HOME/$dropbox" 2> /dev/null
        ln -s "$HOME/.Xauthority" "$HOME/$dropbox/" 2> /dev/null
    fi
    HOME="$HOME/$dropbox"
    dbus-launch /home/$USER/.dropbox-dist/dropbox-lnx.x86_64-56.4.94/dropbox start -i &
# /home/$USER/.dropbox-dist/dropbox-lnx.x86_64-56.4.94/dropbox start -i> /dev/null &
sleep 1s 
done
