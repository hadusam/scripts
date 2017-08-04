
#echo "---- check if nvidia driver installed "
#nvidia-smi
echo "---- install CUDA 8.0.61"
wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda_8.0.61_375.26_linux-run
chmod +x cuda_8.0.61_375.26_linux-run
sudo ./`ls cuda_8.0*_linux-run| head -1` --silent --toolkit --samples --verbose
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
