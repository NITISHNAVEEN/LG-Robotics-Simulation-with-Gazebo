# Robotic Simulation App for Liquid Galaxy 

This is the official documentation for the RoboSim app which will be used to control the SO Arm 100 is Liquid Galaxy.

## Prerequisites

- A **Liquid Galaxy** Setup
- An appropriate **Docker Server** running on Linux
- The apk can be found here: [Release-apk](https://drive.google.com/file/d/1qQsTCoSZ16y5J1hEvtBI31xffPm-XZ2Q/view?usp=sharing)
- All of these Liquid Galaxy, Docker Server and your Android App should be connected to a same IP (preferably Wi-Fi)

## Instructions

### The app contains three tabs: 

1. **Views Tab**: From this tab we would be able to launch your Robot in the LG Rig but only after to connect to it via *Settings*.

2. **Controls Tab**: From this tab we would be able to connect to the Server and control your Roboarm.

3. **Settings Tab**: From this tab we would be able to connect to the Liquid Galaxy Rig by both manual entry and QR Scan.

## Controls Tab

<img alt="ss7" src="https://raw.githubusercontent.com/devxdebanjan/Task4/refs/heads/main/robosim_compose_ss7.jpeg" height="500px">

This is the page you land on after launching the app. 

#### The first thing that you have to enter is: **IP address of your Docker Server**

### Here is how to find it:

Step 1. Type in your Linux Terminal the following command: `ip addr`

Step 2. Next find your Wifi IP by looking for an address like : 192.xxx.x.x

That is your Wifi IP:

![ip-address](https://raw.githubusercontent.com/devxdebanjan/Task4/refs/heads/main/robosim_compose_ss5.png)

### Alternate Approach: 

You can directly see your Wifi IP when you run your Docker Server by checking the logs:

![ip-from-log](https://raw.githubusercontent.com/devxdebanjan/Task4/refs/heads/main/robosim_compose_ss4.png)

#### Now enter this IP in your Controls Tab and hit Connect. Your App will be connected to the Server and show status "Connected"": 

<img alt="ss8" src="https://raw.githubusercontent.com/devxdebanjan/Task4/refs/heads/main/robosim_compose_ss8.jpeg" height="500px">

#### Now Scroll Down and toggle the "Continuous Mode" option

Now you can control the robot with help of the sliders in the app from your mobile phone in real-time.

## Settings Tab

This is the page for connecting to your Liquid Galaxy Rig.

<img alt="settingspage" src="https://raw.githubusercontent.com/devxdebanjan/Task4/refs/heads/main/Screenshot%202025-07-08%20194120.png" height="500px">

Here you can either enter your Liquid Galaxy Rig details manually or use the all new *QR Code feature* to scan your Liquid Galaxy QR and get the details instantly.

### Scanning the QR:

To scan the QR Code, tap on the "Scan your LG Rig QR Code option".

Allow the camera permission for the app and then point the camera towards your QR Code.

> You can also choose to **Flip the Camera** or **Turn on the Flashlight** if necessary using the options on the screen.

Your QR Code will only be scanned successfully if it is in the correct format.

```bash
# Correct format is:
{
  "username": "YOUR_USERNAME",
  "ip": "192.168.XX.XXX",
  "port": "YOUR_PORT",
  "password": "YOUR_ACTUAL_PASSWORD",
  "screens": "5"
}
```

### Connecting: 

Now that you have your details saved, go forward and connect to your Liquid Galaxy Rig. On successful(or unsuccessful) connection, you will get an appropriate notification.

<img alt="connection-successful" src="https://raw.githubusercontent.com/devxdebanjan/Task4/refs/heads/main/Screenshot%202025-07-08%20203400.png" height="500px">

## Views Tab

The Views tab will help you launch your Robot from your App directly onto your Liquid Galaxy Rig.

<img alt="views-tab" src="https://raw.githubusercontent.com/devxdebanjan/Task4/refs/heads/main/Screenshot%202025-07-08%20203729.png" height="500px">

In the Server IP address box, enter the same IP that you entered in the **Controls Tab**.

Now you can finally launch The SO Arm 100 Robot in your Liquid Galaxy by tapping on the `Launch Robot View`.

![launched-rig](https://github.com/devxdebanjan/Task4/blob/main/Screenshot%202025-07-08%20204948.png?raw=true)

You can close the Stream by tapping on the `Close Robot View` button.

The Shutdown and Reboot buttons perform similar functions to every other Liquid Galaxy rig.