#!/bin/bash

if [ $USER != root ]; then
	echo You must be root. Please log in root.
	exit 1
fi

for user in root $(ls /home); do
	if [ $user = root ]; then
		home_dir=/root
	else
		home_dir=/home/$user
	fi

	vimrc=$home_dir/.vimrc

	if [ -f $vimrc ]; then
		echo \"$vimrc\" already exists!
	else
		echo \"$vimrc\" not found. creating the file..
		touch $vimrc
		chown $user:$user $vimrc
	fi

	while read BASHRC_LINE; do
		if [ $(cat $vimrc | grep "$BASHRC_LINE" | wc -m) -eq 0 ]; then
			echo BASHRC_LINE=$BASHRC_LINE
			echo $BASHRC_LINE >> $vimrc
		fi
	done < bashrc.custom
done

if [ $(cat /etc/bashrc | grep "alias vi" | wc -m) -eq 0 ]; then
	echo /etc/bashrc has not \'alias vi\'. adding aliases..
	echo alias vi=vim >> /etc/bashrc
fi

