<h1 align="center"> Liquid Galaxy Robotics Simulation</h1>
<p align="center">
  <img alt="LGSim" src="https://raw.githubusercontent.com/devxdebanjan/Task4/refs/heads/main/RoboticSimLGlogo.png" height="300px">
</p>  
This is the official documentation for the Robotics Simulation Project for Liquid Galaxy under the Google Summer of Code Program 2025.

Below you will find the instructions to simulate the SO-Arm-100 in a Gazebo environment and control it through your browser.

## Table of Contents
- [Docker Install](#docker-install) [Recommended]
- [Build from Source](#build-from-source)

## Docker Install

### Prerequisites
For simulating this Robotic Arm through Docker, you would need docker engine installed and configured in your system. In addition to this you would also need a functional browser to control this arm.

### Instructions
- ### Simulation
    - First Pull the necessary Docker Image
        ```bash
        docker pull devxdebanjan/lg_dockerhub:arm_controlv1
        ```
    - Next run this in your terminal to give it display permissions
        ```bash
        xhost +
        ```
    - Next run this Image with the necessary configuration as given below
        ```bash
        docker run -it \
        --network=host \
        --ipc=host \
        --env="DISPLAY=$DISPLAY" \
        --env="QT_X11_NO_MITSHM=1" \
        --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
        --device=/dev/dri:/dev/dri \
        devxdebanjan/lg_dockerhub:arm_controlv1
        ```
A Gazebo Window now appears with the simulated SO Arm 100 Roboarm.
Basic Gazebo Window Controls: <br>
1. Hold Left Click Button and Move to See Around the World
2. Hold Scroll Button and Move Around to Rotate
3. Hold Right Click Button and Move or just simply Scroll to Zoom in and out.

- ### Controls
    Download this [controller html](https://github.com/LiquidGalaxyLAB/LG-Robotics-Simulation-with-Gazebo/blob/so_arm_dev/controller_webpage.html) and store it in any directory of your choice.

    Next open this html page in any browser of your choice while the container is running and you can see the Gazebo world.

    Click Connect and Scroll Down to see if the `Continuous Control` option is already active. 

    Now Move the slider left or right and Control the RoboArm accordingly.

## Build from Source

### Prerequisites
Here we would have quite a few prerequisites. 
- Recommended OS: Ubuntu 22.04 LTS (CodeName: Jammy)
- ROS Version: ROS2 Humble
- Gazebo Version: Gazebo Fortress
- Git 
### Additional Dependencies
- ros2_control

    ```bash
    sudo apt install ros-humble-ros2-control ros-humble-ros2-controllers ros-humble-ign-ros2-control
    ```

-  rosbridge suite

    ```bash
    sudo apt install ros-humble-rosbridge-server
    ```
### Instructions

Now that you have your dependencies installed, run these commands to build the package. 
> Currently the Git repository is private so you have to link your Github with your local system through PAT(Personal Access Token) but once the repository is public this would be a problem any more.

```bash
cd
echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
mkdir -p lg_arm_ws/src/
git clone --branch so_arm_dev --single-branch https://github.com/LiquidGalaxyLAB/LG-Robotics-Simulation-with-Gazebo.git lg_arm
```

Now you will have a `lg_arm_ws` directory in your home directory and `lg_arm` package inside `lg_arm_ws/lg_arm`

Next go forward and open a new terminal and navigate to the workspace and build it.
 ```bash
 cd lg_arm_ws/
 colcon build --symlink-install
 ```
Now source the workspace and launch your ROS2 launch file.
```bash
source ~/lg_arm_ws/install/setup.bash
ros2 launch lg_arm gazebo.launch.xml
```
You will now see a Gazebo window pop up in your system along with the SO Arm 100 simulated inside it.

Next download this [controller html](https://github.com/LiquidGalaxyLAB/LG-Robotics-Simulation-with-Gazebo/blob/so_arm_dev/controller_webpage.html) and store it in any directory of your choice.
Now open this html page in any browser of your choice while Gazebo is running and you can see the Robotic Arm inside it.

Click Connect and Scroll Down to see if the `Continuous Control` option is already active. 
Now you can control the Robotic Arm from your Browser.
