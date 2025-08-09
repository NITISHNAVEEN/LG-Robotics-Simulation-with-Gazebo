FROM osrf/ros:humble-desktop

# Install required dependencies
RUN apt-get update && apt-get install -y \
    ros-humble-cv-bridge \
    python3-opencv \
    python3-pip \
    && apt-get clean

# Install Flask
RUN pip install flask \
    flask-socketio

# Set working directory
WORKDIR /app
COPY . /app

# Source ROS 2 before running Flask + ROS2 thread
CMD ["/bin/bash", "-c", "source /opt/ros/humble/setup.bash && python3 app.py"]
