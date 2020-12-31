#!/usr/bin/env bash
echo "#########################################"
echo "# This script requires sudo priviledge! #"
echo "#########################################"
echo "# Install dependencies"
sudo apt update
sudo apt install stow inotify-tools git tree -y
git clone https://github.com/gitwatch/gitwatch.git /tmp/gitwatch
cd /tmp/gitwatch
sudo install -b gitwatch.sh /usr/local/bin/gitwatch
cd -
echo "# Setup config directory"
DOT_BOSS_DIR=${HOME}/.config/dotboss
mkdir -p ${DOT_BOSS_DIR}
if [ ! -f ${HOME}/.config/dotboss/dotboss@.service ]; then
    cp dotboss.service ${HOME}/.config/dotboss
fi
echo "# Install dotboss"
sudo install -b dotboss.sh /usr/local/bin/dotboss
echo "# Done!"
