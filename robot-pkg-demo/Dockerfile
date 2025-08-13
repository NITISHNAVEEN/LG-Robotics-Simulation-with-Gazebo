FROM osrf/ros:humble-desktop-full

# Fix the expired ROS GPG key by updating the existing keyring
RUN apt-get update || true && \
    apt-get install -y curl gnupg2 lsb-release && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros2-latest-archive-keyring.gpg && \
    apt-get update

RUN curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
RUN apt-get update && \
    apt-get install ignition-fortress -y 

RUN apt-get update && \
    apt-get install -y \
    ros-humble-ros2-control \
    ros-humble-ros2-controllers \
    ros-humble-ign-ros2-control \
    ros-humble-rosbridge-server
    
# Setup ROS environment
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc

# Copy only the source code into the workspace's src directory
COPY ./src /home/SO_arm_100_ws/src

# Make the script executable during the build
RUN chmod +x /home/SO_arm_100_ws/src/lg_arm/controller/demo.py

WORKDIR /home/SO_arm_100_ws

RUN /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && colcon build"

RUN echo "source /home/SO_arm_100_ws/install/setup.bash" >> ~/.bashrc

CMD ["/bin/bash", "-c", "source /opt/ros/${ROS_DISTRO}/setup.bash && source /home/SO_arm_100_ws/install/setup.bash && ros2 launch lg_arm demo.launch.xml"]
