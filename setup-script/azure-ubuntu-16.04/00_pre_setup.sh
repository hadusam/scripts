echo "---- install mosh"
sudo apt-get -o Acquire::ForceIPv4=true update
sudo apt-get update
sudo apt install mosh htop --assume-yes

echo "---- change locale and timezone"
sudo locale-gen ja_JP.UTF-8
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
sudo dpkg-reconfigure locales
sudo ln -sf /usr/share/zoneinfo/Japan /etc/localtime

echo "---- install build essentials"
sudo apt install build-essential cmake --assume-yes 

echo "---- edit module blacklist"
echo "---- additionally write to /etc/modprobe.d/blacklist.conf"
cat << EOF | sudo tee -a /etc/modprobe.d/blacklist.conf
blacklist vga16fb
blacklist rivafb
blacklist nvidiafb
blacklist rivatv
EOF

echo "---- additionally write to /etc/modprobe.d/blacklist-nouveau.conf"
cat << EOF | sudo tee -a /etc/modprobe.d/blacklist-nouveau.conf
blacklist nouveau
blacklist lbm-nouveau
options nouveau modeset=0
alias nouveau off
alias lbm-nouveau off
EOF

echo "---- additionally write to /etc/modprobe.d/nouveau-kms.conf"
cat << EOF | sudo tee -a /etc/modprobe.d/nouveau-kms.conf
options nouveau modeset=0
EOF

echo "---- update intramfs"
sudo update-initramfs -u

echo "---- done."
echo "---- finally, please reboot"
