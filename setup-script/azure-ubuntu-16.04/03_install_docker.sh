echo "--- install docker for Ubuntu"
sudo apt-get remove docker docker-engine docker.io
sudo apt update 
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt update
sudo apt install -y docker-ce

echo "--- install docker-compose"
sudo sh -c "curl -L https://github.com/docker/compose/releases/download/1.15.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
sudo chmod +x /usr/local/bin/docker-compose

echo "--- add current user to docker group"
sudo gpasswd -a `id -un` docker

sudo apt upgrade --assume-yes
echo "--- finish. please reboot"
