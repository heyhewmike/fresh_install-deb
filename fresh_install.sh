#!/bin/bash
# parts of this program were taken from Jeremy Carter's article
# https://linuxstans.com/things-most-people-do-after-installing-debian/
# I would like to thank Jeremy for his peer review and assistance with this
# program.
#
# Copyright © 2021 Michael Kudrak <mike@heyhew.net>
#
# Published under the GNU GPL V3 License
# 
# By using this software you have agreed to the
# LICENSE TERMS outlined in the file titled
# LICENSE contained in the top-level directory of
# this project.
#
# This program will only work for NVIDIA Cards that are not
# listed as "legacy GPUs" here
# https://wiki.debian.org/NvidiaGraphicsDrivers

# start of project code
# the 'clear' and 'sleep' were added to make the program
# easier to follow during the running of it
clear
# Query if they need current user to have sudo permissions
echo "Does this user require sudo privilages to be added? yes or no"
read premissions
echo " "
# Query user if Nvidia graphics is installed
echo "Do you have a Nvidia Graphics card? yes or no"
read graphics
clear
# back up the newly installed sources
echo "Backing up the sources file" && sleep .5
su - -c 'cp /etc/apt/sources.list /etc/apt/list.sources.org'
# enable contrib and non-free
clear && echo "Adding contrib and non-free" && sleep .5
# grep is required so that sed does not edit the same line with multiple runs of this program
su - -c 'cat /etc/apt/sources.list | grep "contrib non-free" || sed -i "s/main/main contrib non-free/g" /etc/apt/sources.list'
# update apt & upgrade & install lsb-release
clear && echo "Updating & Upgrading apt & Installing lsb-release" && sleep .5
su - -c 'apt update && apt -y upgrade && apt install -y lsb-release'
clear && echo "Adding backports" && sleep .5
# makes the sources.list.d directory if it is not there
su - -c 'mkdir -p /etc/apt/sources.list.d'
# adds the backports for the $(lsb_release -cs){identifies the name of the version} to a file in the directory
su - -c 'cat "deb http://deb.debian.org/debian $(lsb_release -cs)-backports main contrib non-free" >> /etc/apt/sources.list.d/backports.list'
clear && echo "Updating & Upgrading - Again - Backports" && sleep .5
su - -c 'apt update && apt -y upgrade && apt install -y firmware-linux firmware-misc-nonfree'
# download slack installer to downloads
clear && echo "Downloading Slack"
echo "This is Version 4.13.0"
echo "The script will need a new download URL if you want a newer version" && sleep 3
# sets the current signed in user as a variable so the slack
# installer gets downloaded to the correct file path
export currentuser=$(pwd | cut -d/ -f3)
cd /home/${currentuser}/Downloads/ && wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.13.0-amd64.deb && clear
# install slack
echo "Installing Slack" && sleep .5
su - -c 'apt install -y ./slack-desktop-*.deb'
# begins sudo rights
if [ $permission = yes ]; then
# setting user to sudo rights
clear
echo "Setting sudo permissions"
su - -c 'gpasswd -a '${currentuser}' sudo'
sleep .5
else
clear && echo "sudo permissions were not set" && sleep .5
fi
# update nvidia
clear
if [ $graphics = yes ]; then
echo "Installing required tools"
su - -c 'apt install -y nvidia-detect linux-headers-amd64'
su - -c 'apt install -y -t buster-backports linux-image-amd64 nvidia-driver firmware-misc-nonfree && apt autoremove'
clear && echo "A Reboot will be required to complete install of NVIDIA drivers" && sleep 2
else
echo "No Nvidia Graphics Card"
fi
clear
echo "Your system is now updated and ready for use"
echo "Do you want to reboot now? yes or no"
read rbt
clear
if [ $rbt = yes ]; then
echo "rebooting shortly" && sleep 1
# reboot
su - -c 'shutdown -r now'
else
echo "Thank you for running this program" && sleep 5 && clear
fi
