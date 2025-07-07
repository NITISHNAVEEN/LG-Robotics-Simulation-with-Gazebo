## This is the Setup Documentation for Docker Server of Robotics Simulation for Liquid Galaxy Project

### Prerequisites

- OS: Linux
- Docker and Docker Compose v2

### Instructions

Setting up the Docker Server requires two steps: 

1. Clone the `docker-compose.yaml` file:- <br> Sample Code: 

```bash
cd
git clone --branch docker-compose-config --single-branch https://github.com/LiquidGalaxyLAB/LG-Robotics-Simulation-with-Gazebo.git deploy_robosim
```
In case the git does not work for now as it is a private repository, you can make a directory place the docker-compose.yaml inside it. Sample code:
```bash
mkdir ~/deploy_robosim
cd ~/deploy_robosim
# Make a file named docker-compose.yaml here and copy the contents from this repository's branch docker-compose-config
```

At the end of step 1 your file structure should look like this:

![ss1](https://raw.githubusercontent.com/devxdebanjan/Task4/refs/heads/main/robosim_compose_ss1.png)

2. Run this file:- 

This is very simple.<br> 
- Just go to the location where you saved your file. If you are following everything in this documentation, the file location should be `~/deploy_robosim`
- Open ports for GUI apps in docker using `xhost +`
- Run the command `docker compose up`<br>
Sample code: 
```bash
cd ~/deploy_robosim
xhost +
docker compose up
```
If everything is fine, you will see something like this: 

![ss2](https://raw.githubusercontent.com/devxdebanjan/Task4/refs/heads/main/robosim_compose_ss2.png)

> Note: <br>
If you face any problem while running this ```docker compose up``` command, that can be due to a container with the same name running in your server already.<br>
To stop something like this: type ```docker container prune``` in the terminal. 

## Further Steps

### 1. How to see the Robotic Environment Stream?

Search for an IP address in the terminal logs that appear after you run `docker compose up` command. Here you will find an address starting with preferably something like: 192.xxx. 

![ss4](https://raw.githubusercontent.com/devxdebanjan/Task4/refs/heads/main/robosim_compose_ss4.png)

That is your Wifi LAN IP. You can cross check this by typing `ip addr` in your terminal and look for this `wlp` address: 

![ss5](https://raw.githubusercontent.com/devxdebanjan/Task4/refs/heads/main/robosim_compose_ss5.png)

Now open any browser of your choice and type this address with following ports numbers 8081 to 8085 and you can see the stream.

![ss6](https://raw.githubusercontent.com/devxdebanjan/Task4/refs/heads/main/robosim_compose_ss6.png)

### 2. How to Control my Robot?

2.1 Download the RoboSim flutter apk and Enter your network ip here: 

![ss7](https://raw.githubusercontent.com/devxdebanjan/Task4/refs/heads/main/robosim_compose_ss7.png)

Now connect to the server and scroll down to activate Continuous Mode. 

![ss8](https://raw.githubusercontent.com/devxdebanjan/Task4/refs/heads/main/robosim_compose_ss8.png)

Now you can control the robot with help of the sliders in the app fro your mobile phone in real-time. 

2.2 Download this [controller html](https://github.com/LiquidGalaxyLAB/LG-Robotics-Simulation-with-Gazebo/blob/so_arm_dev/controller_webpage.html) and store it in any directory of your choice.

Next open this html page in any browser of your choice while the container is running and you can see the Gazebo world.

![ss9](https://raw.githubusercontent.com/devxdebanjan/Task4/refs/heads/main/robosim_compose_ss9.png)

Click Connect and Scroll Down to see if the `Continuous Control` option is already active. 

![ss10](https://raw.githubusercontent.com/devxdebanjan/Task4/refs/heads/main/robosim_compose_ss10.png)

Now Move the sliders left or right and Control the RoboArm accordingly.