# Docker Install for the Server

Source of this Documentation: https://docs.docker.com/engine/install/ubuntu/

## OS Requirements

To install Docker Engine, you need the 64-bit version of one of these Ubuntu versions:
- Ubuntu Oracular 24.10
- Ubuntu Noble 24.04 (LTS)
- Ubuntu Jammy 22.04 (LTS)

## Uninstall old versions

Before you can install Docker Engine, you need to uninstall any conflicting packages.

Your Linux distribution may provide unofficial Docker packages, which may conflict with the official packages provided by Docker. You must uninstall these packages before you install the official version of Docker Engine.

The unofficial packages to uninstall are:
- docker.io
- docker-compose
- docker-compose-v2
- docker-doc
- podman-docker

Moreover, Docker Engine depends on `containerd` and `runc`. Docker Engine bundles these dependencies as one bundle: `containerd.io`. If you have installed the `containerd` or `runc` previously, uninstall them to avoid conflicts with the versions bundled with Docker Engine.

Run the following command to uninstall all conflicting packages:
```bash
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

`apt-get` might report that you have none of these packages installed.

Images, containers, volumes, and networks stored in `/var/lib/docker/` aren't automatically removed when you uninstall Docker. If you want to start with a clean installation, and prefer to clean up any existing data, read the [uninstall Docker Engine](https://docs.docker.com/engine/install/ubuntu/#uninstall-docker-engine) section.

## Install Docker
Before you install Docker Engine for the first time on a new host machine, you need to set up the Docker `apt` repository. Afterward, you can install and update Docker from the repository.

1. Set up Docker's `apt` repository

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

2. Install the Docker packages.

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
3. Verify that the installation is successful by running the `hello-world` image:

```bash
sudo docker run hello-world
```

This command downloads a test image and runs it in a container. When the container runs, it prints a confirmation message and exits.

You have now successfully installed and started Docker Engine.

## Post Installation Steps

Manage Docker as a non-root user.

To create the `docker` group and add your user:

1. Create the `docker` group.

```bash
sudo groupadd docker
```

2. Add your user to the docker group.

```bash
sudo usermod -aG docker $USER
```

3. Log out and log back in so that your group membership is re-evaluated.

> If you're running Linux in a virtual machine, it may be necessary to restart the virtual machine for changes to take effect.

4. Verify that you can run docker commands without sudo.

```bash
docker run hello-world
```

This command downloads a test image and runs it in a container. When the container runs, it prints a message and exits.

Now you have succesfully created a non root Docker user and you can continue usng Docker for any purposes.

If you initially ran Docker CLI commands using `sudo` before adding your user to the docker group, you may see the following error:

> WARNING: Error loading config file: /home/user/.docker/config.json -
stat /home/user/.docker/config.json: permission denied

This error indicates that the permission settings for the `~/.docker/` directory are incorrect, due to having used the `sudo` command earlier.

To fix this problem, either remove the `~/.docker/` directory (it's recreated automatically, but any custom settings are lost), or change its ownership and permissions using the following commands:

```bash
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "$HOME/.docker" -R
```