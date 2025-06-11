#!/bin/bash
sudo apt update && sudo apt upgrade;
sudo apt autoremove nvidia* --purge;
ubuntu-drivers devices;
sudo apt-get install linux-headers-$(uname -r) build-essential;
# reboot
sudo apt install nvidia-cuda-toolkit;
lspci | grep -i nvidia;
sudo apt install nvidia-driver-550;
sudo apt update && sudo apt upgrade;
# reboot
nvidia-smi;
nvcc --version;
# configure repo for the nvidia-container-toolkit
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
## OPTIONAL EXPERIMENTAL PACKAGES ## NO PROD!
sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list
# refresh apt
sudo apt-get update
# install nvidia-container-toolkit package
sudo apt-get install -y nvidia-container-toolkit
# configure docker - option a: root mode. option b: rootless mode. CHOOSE ONE
# option a: root mode
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
# option b: rootless mode
nvidia-ctk runtime configure --runtime=docker --config=$HOME/.config/docker/daemon.json
systemctl --user restart docker
sudo nvidia-ctk config --set nvidia-container-cli.no-cgroups --in-place
# OPTIONAL - configure containerd for kubernetes
sudo nvidia-ctk runtime configure --runtime=containerd
sudo systemctl restart containerd
# OPTIONAL - configure containerd for nerdctl
nerdctl run --gpus=all
# OPTIONAL - configure CRI-O
sudo nvidia-ctk runtime configure --runtime=crio
sudo systemctl restart crio
# OPTIONAL - configure CDI for podman
https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/cdi-support.html
# run a test load with docker
sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi