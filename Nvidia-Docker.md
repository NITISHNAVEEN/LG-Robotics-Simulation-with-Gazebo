# Nvidia Docker Setup

For utilising GPU Acceleation while running the Docker Image on a Server, it would need to install Nvidia Drivers if not installed already.

To Check if the Driver is already installed and correctly configured, use the command `nvidia-smi` . If you can see the details of your GPU and driver skip to the Runtime Configuration Zone. 

Sample Correct Output:
<!-- ![nvidia-smi-configured](assets/nvidia-smi.png) -->

## Nvidia Driver Installation

1. Check the available drivers for your hardware:

```bash
sudo ubuntu-drivers list
```

You should see a list such as the following:
```
nvidia-driver-470
nvidia-driver-470-server
nvidia-driver-535
nvidia-driver-535-open
nvidia-driver-535-server
nvidia-driver-535-server-open
nvidia-driver-550
nvidia-driver-550-open
nvidia-driver-550-server
nvidia-driver-550-server-open
```

2. Install the driver that is considered the best match for your hardware:

```bash
sudo ubuntu-drivers install
```

3. Then reboot:
```bash
sudo reboot
```
4. Now Verify using:
```bash
nvidia-smi
```
If you can see your GPU details in the terminal, you are good to resume your runtime container setup.


## Nvidia Runtime Container Toolkit Installation

Source for this documentation: [here](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#prerequisites)

1. Configure the production repository:
```bash
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```
2. Update the packages list from the repository:
```bash
sudo apt-get update
```
3. Install the `nvidia-container-toolkit`:
```bash
sudo apt-get install -y nvidia-container-toolkit
```
4. Configure Docker to Use the NVIDIA Runtime:
```bash
sudo nvidia-ctk runtime configure --runtime=docker
```
5. Restart Docker to Apply Changes:
```bash
sudo systemctl restart docker
```
6. Configure Containerd to Use the NVIDIA Runtime:
```bash
sudo nvidia-ctk runtime configure --runtime=containerd
```