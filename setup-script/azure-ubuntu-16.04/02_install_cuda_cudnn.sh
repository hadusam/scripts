
#echo "---- check if nvidia driver installed "
#nvidia-smi
echo "---- install CUDA 8.0.61"
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
sudo dpkg -i ./`ls cuda-repo-ubuntu*.deb | head -1`
sudo apt update
sudo apt install -y cuda
echo "---- add path to /etc/profile"
cat << EOF | sudo tee -a /etc/profile
# CUDA
export PATH=$PATH:/usr/local/cuda/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64
EOF

echo "---- install cudnn v5.1"
tar xvzf cudnn/cudnn-8.0-linux-x64-v5.1.tgz
sudo cp cuda/include/* /usr/local/cuda/include/.
sudo cp cuda/lib64/* /usr/local/cuda/lib64/.
sudo apt update 
sudo apt upgrade --assume-yes
echo "---- please reboot"
