#!/bin/bash

NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'

radio_ctrl=`pwd`
cd ..
audio_dev="usb"

printf "${GREEN}.Installing various packages\n${YELLOW}"

#python packages
sudo apt-get -y install python-smbus i2c-tools python-pip
#libraries + tools
sudo apt-get -y install git pkg-config libevent-pthreads-2.0-5 libao-dev libgnutls28-dev libmad0-dev libfaad-dev libjson0-dev libgcrypt11-dev
#fetch music player
sudo apt-get -y install pianobar
#install Pyro4
pip install Pyro4

function pexpect_install {
	if [ -f $HOME/pexpect-2.3.tar.gz ]; then
		return
	fi
	printf "${GREEN}.Get pexpect and install\n${YELLOW}"
	wget http://pexpect.sourceforge.net/pexpect-2.3.tar.gz
	tar xzf pexpect-2.3.tar.gz
	cd pexpect-2.3
	sudo python ./setup.py install
	cd ..
	sudo rm -r pexpect-2.3
	return
}

function setup_audio {
	if [ "$audio_dev" != "default" ]; then
		printf "${YELLOW} You have specified that you are using a $audio_dev audio device."
		printf "${YELLLOW} Setting up $audio_dev audio device.\n"
		cd $radio_ctrl/settings/$audio_dev
		sudo rsync -aH etc/ /etc/
	fi
}

function setup_pandora {
	cd
	mkdir -p .config/pianobar
	mkdir -p .config/pianobar/scripts

	cd .config/pianobar
	ln -sf $radio_ctrl/settings/config .

	printf "${GREEN}\nSetting up your pandora radio\n"
	printf "${GREEN}.\nEnter username for pandora${NONE}\n"
	read uname

	sed -i "s/__user__/$uname/" ~/.config/pianobar/config

	printf "${GREEN}. Enter password for pandora${NONE}\n"
	read psswd

	sed -i "s/__pass__/$psswd/" ~/.config/pianobar/config

	script_path="$HOME/.config/pianobar/scripts/eventcmd.sh"
	sed -i "s@__eventscript__@$script_path@" ~/.config/pianobar/config

	printf "${GREEN}. Setting up TLS for pianobar\n${YELLOW}"
	fingerprint=`openssl s_client -connect tuner.pandora.com:443 < /dev/null 2> /dev/null | openssl x509 -noout -fingerprint | tr -d ':' | cut -d'=' -f2` && echo tls_fingerprint = $fingerprint >> ~/.config/pianobar/config
	cd scripts
	ln -sf $radio_ctrl/settings/eventcmd.sh .
	cd ~/.config/pianobar

	printf "${YELLOW}\nReboot to finish installation. After reboot\n"
	printf "${YELLOW} Type pianobar to run music. Type )))))) to increase volume\n${NONE}"
}
pexpect_install
setup_audio
setup_pandora
cd $radio_ctrl
