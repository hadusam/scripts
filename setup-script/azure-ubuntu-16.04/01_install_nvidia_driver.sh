echo "---- install kernel compiler"
sudo apt install -y linux-image-extra-virtual linux-source linux-headers-`uname -r`
echo "---- install nvidia driver"
wget http://jp.download.nvidia.com/XFree86/Linux-x86_64/375.66/NVIDIA-Linux-x86_64-375.66.run
chmod +x NVIDIA-Linux-x86_64-*.run
sudo ./`ls NVIDIA-Linux-x86_64-*.run | head -1` 
echo "---- please reboot after finish"
