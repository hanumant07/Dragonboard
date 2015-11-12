#!/bin/bash

radio_ctrl=`pwd`
cd ..
staging=`pwd`
GREEN='\033[0;31m'

printf "${GREEN}.Installing various packages"

#python packages
sudo apt-get -y install python-smbus i2c-tools python-pip
#libraries + tools
sudo apt-get -y install git pkg-config libevent-pthreads-2.0-5 libao-dev libgnutls28-dev libmad0-dev libfaad-dev libjson0-dev libgcrypt11-dev
#fetch music player
sudo apt-get -y install pianobar
#install Pyro4
pip install Pyro4

printf "${GREEN}.Get pexpect and install"

wget http://pexpect.sourceforge.net/pexpect-2.3.tar.gz
tar xzf pexpect-2.3.tar.gz
cd pexpect-2.3
sudo python ./setup.py install
cd ..
sudo rm -r pexpect-2.3

printf "${GREEN}. Get python sources"

cd
mkdir -p .config/pianobar
mkdir -p .config/pianobar/scripts

cd .config/pianobar
ln -s $radio_ctrl/settings/config .

printf "${GREEN}. Setting up TLS for pianobar"
fingerprint=`openssl s_client -connect tuner.pandora.com:443 < /dev/null 2> /dev/null | openssl x509 -noout -fingerprint | tr -d ':' | cut -d'=' -f2` && echo tls_fingerprint = $fingerprint >> ~/.config/pianobar/config

cd scripts
ln -s $radio_ctrl/settings/eventcmd.sh .

printf "${GREEN} You have specified that you are using a $1 audio device."
printf "${GREEN} Setting up $1 audio device."

cd $radio_ctrl
sudo mv settings/$1_audio/asound.conf /etc/

cd ~/.config/pianobar
printf "${GREEN} Type nano config. Enter pandora login credentials near top of file user = YOUR_EMAIL_ADDRESS password = YOUR_PASSWORD"
printf "${GREEN} Then you should be able to type pianobar on your commandline and listen to music. Type )))))) to increase volume"
