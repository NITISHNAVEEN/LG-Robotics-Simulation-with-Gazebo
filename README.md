# The Official App to control LG Robotics Simulation

This is how you can simulate and control your Robots in Liquid Galaxy.

## Prerequisites
- Liquid Galaxy Rig Setup
- [Active Docker Server running the Robot Image](https://github.com/LiquidGalaxyLAB/LG-Robotics-Simulation-with-Gazebo/docker-compose-config/README.md#instructions)
- [LAN IP of the Docker Server](https://github.com/LiquidGalaxyLAB/LG-Robotics-Simulation-with-Gazebo/blob/docker-compose-config/README.md#1-how-to-see-the-robotic-environment-stream--how-to-know-my-device-ip-to-be-enetered-in-the-app)

## App Layout

There are four Tabs in the App: **Controls**, **LG Tools**, **Settings** and **About**.

### Controls: 
This is the Landing Page of the App. From the drop down menu, you have to select the same robot that your Docker Server is running. Next connect to the Docker Server and continue to control your Robot through the controllers present in the App.

![Controls](assets/Controls.png)

### LG Tools: 
From here, you can launch and view your Stream in the Liquid Galaxy Rig. You can also Zoom into your Stream.

![LGTools](assets/LGTools.png)

### Settings: 
From here you can Connect to your LG Rig. Scan the QR of your Rig and just tap Connect. In case, that does not work, you can manually enter the details too.

![Settings](assets/Settings.png)

### About: 
To be Added

## Connections

> Before connecting the App to the Server first switch to the preferred Robot that your Docker Server is Running.

There are two connections required in this App:

### 1.  Connecting to the Docker Server: 
As you already have the LAN IP of your Docker Server, go forward and enter that IP Address in the **Connections** block in the **Controls** Tab.

![EnterIP](assets/ControlsIP.png)

Tap **Connect** Button and now your app is connected to your LG Server.

### 2.  Connecting to the LG Rig: 

Navigate to the **Settings** Tab of your App and Tap the QR Code icon to Scan the LG Rig QR. Hold your camera steady while it processes the QR. If the QR is accurately configured the detils appear in the input fields. Or else you can also enter them manually.

Now tap **Connect** to connect to your LG Rig. You receive a Green confirmation notification on successful connection or a Red notification if the connection in not successful.

![Connection](assets/Connection.png)

## Controls

You can either control the Robot or the Video Stream through this App.

### 1. Robot: 

Once you select the appropriate robot your want to control, you can view the controllers present for that Robot under the **Joystick section** in **Controls Tab**. If you have the Connections configured, you will be able to control the Robot in real time from the App.

![Joystick](assets/Joystick.png)

### 2. Video Stream: 

Navigate to the **LG Tools** Tab of your App. Now, tap the **Connect to Video Server** button.
Once connected, tap on **Start Stream** to view your Robot in the Liquid Galaxy Rig. You can also perform all the other LG functions from this App.
You can simultaneously change the Zoom level through slider and show or hide the Logo.



## Exiting the App

Once you are done with your Simulation and Controls, close the LG Stream. Next Disconnect with all the Server IPs and LG Rig before you exit the App.