# ABB IRB 1600 / IRC5 Setup on Arch Linux

This guide outlines how to set up a free/open source simulation environment for the ABB IRB 1600 Manipulator and prepare for connecting to the physical IRC5 controller. We use ROS (via ROS-Industrial), Gazebo, and RViz. Later sections cover integrating custom APIs to hook up LLM and vision processing.

---

## Prerequisites

- **Operating System:** Arch Linux (with KDE Plasma)
- **Privileges:** Sudo access
- **Basic Tools:** Git, CMake, a terminal shell
- **Networking:** Ensure your PC and IRC5 controller are on the same network (for later physical integration).

---

## 1. Install ROS on Arch Linux

*Note: ROS packages on Arch can be installed from the official repositories or AUR. This guide assumes using ROS Noetic, but you may choose another supported distro.*

1.1. **Update your system:**

```bash
sudo pacman -Syu
```

1.2. **Install ROS Noetic Desktop Full:**

```bash
sudo pacman -S ros-noetic-desktop-full
```

1.3. **Set Up ROS Environment:**

Add the following to your `~/.bashrc` (or your shell’s equivalent):

```bash
source /opt/ros/noetic/setup.bash
```

Reload your shell:

```bash
source ~/.bashrc
```

*If you run into package issues, check the [ROS on Arch Wiki](https://wiki.archlinux.org/title/ROS) for updates.*

---

## 2. Create and Configure Your ROS Workspace

2.1. **Create a Catkin Workspace:**

```bash
mkdir -p ~/catkin_ws/src
cd ~/catkin_ws
catkin_make
```

2.2. **Source the Workspace:**

Append the workspace setup to your `~/.bashrc`:

```bash
echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

---

## 3. Install Simulation Tools

3.1. **Install Gazebo (for simulation):**

```bash
sudo pacman -S gazebo
```

3.2. **Ensure RViz is Installed:**

RViz is included in the desktop-full ROS installation. Otherwise, install it:

```bash
sudo pacman -S ros-noetic-rviz
```

---

## 4. Clone and Set Up ABB ROS Packages

We will use the ROS-Industrial packages for ABB robots. These include drivers, URDF/SDF models, and configuration files.

4.1. **Clone Repositories:**

Navigate to your workspace source directory and clone the repositories:

```bash
cd ~/catkin_ws/src
git clone https://github.com/ros-industrial/abb_robot.git
git clone https://github.com/ros-industrial/abb_driver.git
```

*Tip: Check the [ROS-Industrial ABB Wiki](http://wiki.ros.org/Industrial/ABB) for any additional packages (e.g., a dedicated `abb_irb1600_support` if available).*

4.2. **Install Dependencies with rosdep:**

Ensure all dependencies are met:

```bash
cd ~/catkin_ws
rosdep update
rosdep install --from-paths src --ignore-src -r -y
```

4.3. **Build the Workspace:**

```bash
cd ~/catkin_ws
catkin_make
source devel/setup.bash
```

---

## 5. Launch the Simulation Environment

5.1. **Run the Simulation Launch File:**

Many packages include a launch file to start the simulation (often launching Gazebo or RViz). For example:

```bash
roslaunch abb_robot abb_simulation.launch
```

*Note: The name of the launch file may differ. Refer to the repository’s README for details.*

5.2. **Verify in RViz/Gazebo:**

Confirm that the ABB IRB 1600 model appears and can be visualized. Test basic joint movements if provided.

---

## 6. Connecting to the Physical IRC5 Controller

*Before connecting to real hardware, ensure all safety protocols are in place (e.g., emergency stop, restricted operational area).*

6.1. **Network Setup:**

- Connect your Arch Linux machine to the same network as the IRC5.
- Determine the controller’s IP address (commonly something like `192.168.125.1`).

6.2. **Configure the ROS Driver:**

Edit the configuration (often in a YAML or launch file) within the `abb_driver` package to set the controller’s IP. For example, create or modify a configuration file:

```yaml
# config/irc5.yaml
controller_ip: 192.168.125.1
```

6.3. **Launch the Physical Driver:**

Run the driver node to interface with the IRC5:

```bash
roslaunch abb_driver abb_irc5.launch controller_ip:=192.168.125.1
```

*Be sure to refer to the package’s documentation for any required calibration or additional parameters.*

---

## 7. Integrating APIs for LLM and Vision

7.1. **Setting Up ROS Topics/Services:**

- Create topics for sending commands and receiving feedback.
- Use ROS action servers for long-running tasks.

7.2. **Integrate Vision:**

Install OpenCV and ROS packages:

```bash
sudo pacman -S opencv ros-noetic-cv-bridge ros-noetic-image-transport
```

Develop a node that subscribes to a camera topic, processes images (using OpenCV), and publishes results. This node can later be connected to your robot’s control pipeline.

7.3. **Integrate an LLM:**

- Create a custom ROS service (or action server) that accepts high-level commands.
- The service node can call your LLM (or a wrapper around it) and translate its output to robot motion commands.

**Example ROS Python Service:**

```python
#!/usr/bin/env python
import rospy
from std_msgs.msg import String
from your_llm_pkg.srv import LLMCommand, LLMCommandResponse

def process_with_llm(command):
    # Replace with actual LLM call (e.g., via an API)
    return "Processed: " + command

def handle_llm_command(req):
    result = process_with_llm(req.command)
    rospy.loginfo("LLM processed command: %s", result)
    return LLMCommandResponse(result=result)

def llm_server():
    rospy.init_node('llm_server')
    s = rospy.Service('llm_command', LLMCommand, handle_llm_command)
    rospy.spin()

if __name__ == "__main__":
    llm_server()
```

*Replace `your_llm_pkg` and the service message definitions with your own as needed.*

---

## 8. Testing and Safety

- **Start in Simulation:** Validate all nodes and the overall ROS graph in simulation before switching to hardware.
- **Safety Checks:** Always have an emergency stop and test in a controlled environment.
- **Logs & Debugging:** Use `rqt_graph` and `rostopic echo` to troubleshoot communication between nodes.

---

## Cheat Sheet

- **Workspace Setup:**
  ```bash
  mkdir -p ~/catkin_ws/src
  cd ~/catkin_ws
  catkin_make
  echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc
  source ~/.bashrc
  ```

- **Install ROS and Tools:**
  ```bash
  sudo pacman -S ros-noetic-desktop-full gazebo ros-noetic-rviz
  ```

- **Clone ABB Packages:**
  ```bash
  cd ~/catkin_ws/src
  git clone https://github.com/ros-industrial/abb_robot.git
  git clone https://github.com/ros-industrial/abb_driver.git
  ```

- **Build and Source Workspace:**
  ```bash
  cd ~/catkin_ws
  rosdep update
  rosdep install --from-paths src --ignore-src -r -y
  catkin_make
  source devel/setup.bash
  ```

- **Launch Simulation:**
  ```bash
  roslaunch abb_robot abb_simulation.launch
  ```

- **Connect to Physical Controller:**
  ```bash
  roslaunch abb_driver abb_irc5.launch controller_ip:=192.168.125.1
  ```

---

## Exercise: Real-World Application

1. **Simulation Verification:**
   - Launch the simulation environment.
   - In RViz, verify that the IRB 1600 model loads and that you can interact (e.g., move joints via a provided interface).

2. **Network Communication:**
   - Ping the IRC5 controller from your Arch machine to confirm connectivity:
     ```bash
     ping 192.168.125.1
     ```

3. **Vision Node:**
   - Create a simple ROS node that subscribes to a webcam feed, applies a basic OpenCV filter (like edge detection), and republishes the processed image.
   - Test the node using `rqt_image_view`.

4. **LLM Command Service:**
   - Implement the provided ROS service example.
   - Use `rosservice call` to send a text command and observe the log output.

---

## Resources

- [ROS Official Documentation](http://wiki.ros.org/)
- [ROS-Industrial ABB Packages](http://wiki.ros.org/Industrial/ABB)
- [Gazebo Simulator](http://gazebosim.org/)
- [OpenCV](https://opencv.org/)
- [ROS on Arch Wiki](https://wiki.archlinux.org/title/ROS)

---

This guide sets you up with an open source development environment for simulation and control of ABB robot arms. It also provides a framework to integrate advanced AI (LLM) and computer vision models, allowing you to build a modern, flexible robotics API.

*Always review the latest documentation for ROS-Industrial and your ABB packages as updates or package changes may occur.*

Happy hacking!


## Additional Notes

- Similar to Anthropic multistage network attacks paper, use macros for LLM to call to execute commands to the robot through waiting API.
- Strict controls and limits to prevent acctuator damage.
- Set up a database with current locations and degrees of joints, plus historical movements.
- Include vision information using VLLM transformer for decision making process augmentation, possibly use native MMLM.

