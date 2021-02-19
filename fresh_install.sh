#!/bin/bash
# parts were taken from Jeremy Carter's article - https://linuxstans.com/things-most-people-do-after-installing-debian/
#back up the newly installed sources
clear
# Quick query for Nvidia
echo "Do you have Nvidia Graphics card? Yes or No"
read graphics
echo "Backing up the sources file"
cp /etc/apt/sources.list /etc/apt/list.sources.org
# enable contrib and non-free
echo "Adding contrib and non-free"
'cat /etc/apt/sources.list | grep "contrib non-free" || sed -i "s/main/main contrib non-free/g" /etc/apt/sources.list
# update apt
echo "Updating apt"
apt update
# upgrade
echo "Upgrading install"
apt -y upgrade
echo "Installing lsb-release"
apt install -y lsb-release
echo "Adding backports"
mkdir -p /etc/apt/sources.list.d
cd /etc/apt/sources.list.d/
touch backports.list
cat "deb http://deb.debian.org/debian $(lsb_release -cs)-backports main contrib non-free" >> backports.list
echo "Updating & Upgrading - Again - Backports"
apt update && apt -y upgrade
apt install -y firmware-linux firmware-misc-nonfree
# download slack installer to downloads
echo "Downloading Slack"
cd /home/$USER/Downloads/
wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.13.0-amd64.deb
# install slack
echo "Installing Slack"
apt install -y ./slack-desktop-*.deb
# update nvidia
if $graphics = yes
then
echo "Installing required tools"
apt install -y nvidia-detect linux-headers-amd64
apt install -y -t buster-backports linux-image-amd64
apt install -y -t buster-backports nvidia-driver firmware-misc-nonfree
apt autoremove
# reboot
shutdown -r now
else
echo "No Nvidia Graphics"
fi
clear
echo "Your system is now updated and ready for use"
