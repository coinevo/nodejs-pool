#!/bin/bash
echo "This assumes that you are doing a green-field install.  If you're not, please exit in the next 15 seconds."
sleep 15
echo "Continuing install, this will prompt you for your password if you're not already running as root and you didn't enable passwordless sudo.  Please do not run me as root!"
if [[ `whoami` == "root" ]]; then
    echo "You ran me as root! Do not run me as root!"
    exit 1
fi
CURUSER=$(whoami)
sudo timedatectl set-timezone Etc/UTC
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install ntp build-essential cmake pkg-config libboost-all-dev libssl-dev libzmq3-dev libunbound-dev libsodium-dev libunwind8-dev liblzma-dev libreadline6-dev libldns-dev libexpat1-dev doxygen graphviz libpgm-dev
cd ~
git clone https://github.com/coinevo/nodejs-pool.git
sudo systemctl enable ntp
cd /usr/local/src
sudo git clone --recursive https://github.com/coinevo/coinevo.git
cd coinevo
sudo git checkout master
sudo USE_SINGLE_BUILDDIR=1 make -j$(nproc) || sudo USE_SINGLE_BUILDDIR=1 make || exit 0
sudo cp ~/nodejs-pool/deployment/coinevo.service /lib/systemd/system/
sudo useradd -m coinevodaemon -d /home/coinevodaemon
sudo systemctl daemon-reload
sudo systemctl enable coinevo
sudo systemctl start coinevo
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
source ~/.nvm/nvm.sh
nvm install v8.11.3
nvm alias default v8.11.3
cd ~/nodejs-pool
npm install
npm install -g pm2
openssl req -subj "/C=IT/ST=Pool/L=Daemon/O=Mining Pool/CN=mining.pool" -newkey rsa:2048 -nodes -keyout cert.key -x509 -out cert.pem -days 36500
cd ~
sudo env PATH=$PATH:`pwd`/.nvm/versions/node/v8.11.3/bin `pwd`/.nvm/versions/node/v8.11.3/lib/node_modules/pm2/bin/pm2 startup systemd -u $CURUSER --hp `pwd`
sudo chown -R $CURUSER ~/.pm2
echo "Installing pm2-logrotate in the background!"
pm2 install pm2-logrotate
echo "You're setup with a leaf node!  Congrats"
