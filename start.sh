#!/bin/bash

if [ $USER != root ]; then
	echo "You must be root. Please log in root."
	exit 1
fi

echo -e "\n---------------------- Your System Info ----------------------"
echo " - BASE_OS: $(uname -o)"
echo " - KERNEL_VERSION: $(uname -r)"
echo " - ARCHITECTURE: $(arch)"
OS_VERSION=$(awk '{print $3}' /etc/redhat-release)
if [ $OS_VERSION == 'release' ]; then
	OS_VERSION=$(awk '{print $4}' /etc/redhat-release)
	#OS_VERSION=$(expr substr $OS_VERSION 1 3)
fi
echo " - OS_VERSION: $OS_VERSION"
ALL_USER_LIST="root $(ls /home)"
echo " - USERS: $ALL_USER_LIST"
echo " - HOSTNAME: $(hostname)"
echo " - DNS_NAMESERVER:" $(cat /etc/resolv.conf | grep 'nameserver')
echo -e "--------------------------------------------------------------\n"

if [ $(yum list installed | grep vim | awk '{print $1}' | wc -w) -le 1 ]; then
	echo -e "It is assumed that you have minimal-vim or classic vi. (Installed: $(yum list installed | grep vim | awk '{print $1}'))\n"
	echo "Do you want to install vim-enhaced? [y/n]: "
	read REPLY
	if [ $REPLY	== "y" ]; then
		yum install vim-enhanced	
	fi
fi

function FUNC_SET_INDIVIDUAL_VIMRC(){
	local USER_LIST=$*
	for user in $USER_LIST; do
		if [ $user = root ]; then
			local VIMRC_FILE=/root/.vimrc
		else
			local VIMRC_FILE=/home/$user/.vimrc
		fi

		if [ -f $VIMRC_FILE ]; then
			echo "$VIMRC_FILE already exists."
		else
			echo "$VIMRC_FILE not found. creating automatically"
			touch $VIMRC_FILE
			chown $user:$user $VIMRC_FILE
		fi

		while read BASHRC_LINE; do
			if [ $(cat $VIMRC_FILE | grep "$BASHRC_LINE" | wc -m) -eq 0 ]; then
				echo "BASHRC_LINE=$BASHRC_LINE"
				echo $BASHRC_LINE >> $VIMRC_FILE	
			fi
		done < bashrc.custom
	done
}

function FUNC_SET_GLOBAL_BASHRC(){
	if [ $(cat /etc/bashrc | grep "alias vi" | wc -m) -eq 0 ]; then
		echo "DEPRECATED"
		#echo "/etc/bashrc has not 'alias vi'. adding alias.."
		#echo alias vi=vim >> /etc/bashrc
	fi
}

while : # infinite loop
do
	echo " 1. FUNC_SET_GLOBAL_BASHRC"
	echo " 2. FUNC_SET_INDIVIDUAL_VIMRC"
	echo -n '$ '
	read TOOL_CMD
	case $TOOL_CMD in	
		1 | FUNC_SET_GLOBAL_BASHRC)
			FUNC_SET_GLOBAL_BASHRC;;
		2 | FUNC_SET_INDIVIDUAL_VIMRC)
			FUNC_SET_INDIVIDUAL_VIMRC $ALL_USER_LIST;;
		exit | EXIT | Exit)
			echo Bye.
			exit 0;;
		*)
			echo What are you doing..?;;
	esac
done
