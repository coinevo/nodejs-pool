#!/bin/bash
echo "This assumes that you have a standard nodejs-pool install, and will patch and update it to the latest stable builds of Coinevo."
sleep 15
echo "Continuing install, this will prompt you for your password if you didn't enable passwordless sudo.  Please do not run me as root!"
cd /usr/local/src/coinevo &&\
sudo git checkout .  &&\
sudo git checkout master &&\
sudo git pull &&\
sudo git checkout master &&\
sudo git submodule init &&\
sudo git submodule update &&\
sudo rm -rf build &&\
(sudo USE_SINGLE_BUILDDIR=1 make -j$(nproc) || sudo USE_SINGLE_BUILDDIR=1 make) &&\
echo "Done building the new Coinevo daemon! Please go ahead and reboot Coinevo with: sudo systemctl restart Coinevo as soon as the pool source is updated!"
