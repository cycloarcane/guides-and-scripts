# Specialized Topics

Guides for robotics, gaming on Linux, and advanced development workflows.

## 📂 Subcategories

### [Robotics](robotics/)
Robot simulation, control systems, and ROS integration

**Guides:**
- `ABB-OPEN-SOURCE.md` - ABB IRB 1600 robot simulation on Arch Linux
  - ROS (Robot Operating System) setup
  - Gazebo physics simulation
  - RViz visualization
  - Preparation for IRC5 controller connection
  - Future: LLM and vision processing integration

### [Gaming](gaming/)
Linux gaming, VR setup, and game compatibility

**Guides:**
- `LinuxVR.md` - HP Reverb G2 VR headset on Arch Linux
  - Monado OpenXR runtime configuration
  - SteamVR integration and compatibility
  - Controller tracking setup (Valve Index controllers)
  - Linux VR limitations and workarounds
  - Hybrid graphics (iGPU + dGPU) configuration

### [Development](development/)
Code migration, language conversion, and development tooling

**Guides:**
- `py-to-ts-deepresearch.md` - Converting Python OSINT tools to TypeScript MCP servers
  - FastMCP to MCP protocol conversion
  - TypeScript project setup and architecture
  - MCPO and Open WebUI compatibility
  - CLI integration and WebSocket support
  - Type safety and error handling

## 🎯 Quick Start

**Set up robot simulation:**
→ Follow [ABB-OPEN-SOURCE.md](robotics/ABB-OPEN-SOURCE.md)

**Get VR working on Linux:**
→ Configure with [LinuxVR.md](gaming/LinuxVR.md)

**Migrate Python tools to TypeScript:**
→ Use [py-to-ts-deepresearch.md](development/py-to-ts-deepresearch.md)

## 🔑 Key Technologies

### Robotics
- **ROS:** Robot Operating System (Noetic/Humble)
- **Simulation:** Gazebo, RViz
- **Robots:** ABB IRB 1600, IRC5 controller
- **Future Integration:** LLM control, computer vision

### Gaming
- **VR Runtime:** Monado OpenXR
- **Game Platforms:** Steam, SteamVR (compatibility layer)
- **Hardware:** HP Reverb G2, Valve Index controllers
- **Graphics:** NVIDIA PRIME, hybrid GPU switching

### Development
- **Languages:** Python → TypeScript conversion
- **Protocols:** FastMCP → MCP (Model Context Protocol)
- **Frontends:** MCPO, Open WebUI
- **Tools:** Node.js, pnpm, TypeScript compiler

## 📊 Complexity Levels

| Topic | Guide | Difficulty | Prerequisites |
|-------|-------|------------|---------------|
| Robot Simulation | [ABB-OPEN-SOURCE.md](robotics/ABB-OPEN-SOURCE.md) | Advanced | ROS knowledge, Linux experience |
| Linux VR | [LinuxVR.md](gaming/LinuxVR.md) | Intermediate | GPU drivers, Steam installed |
| Code Migration | [py-to-ts-deepresearch.md](development/py-to-ts-deepresearch.md) | Advanced | Python & TypeScript proficiency |

## 🛠️ Common Tasks

### Robotics Setup

```bash
# Install ROS (Noetic for Ubuntu 20.04 / Humble for newer)
sudo pacman -S ros-noetic-desktop-full  # Arch (if available)

# Install Gazebo and RViz
sudo pacman -S gazebo ros-noetic-gazebo-ros-pkgs
sudo pacman -S ros-noetic-rviz

# Source ROS environment
source /opt/ros/noetic/setup.bash

# Clone ABB robot packages
mkdir -p ~/catkin_ws/src
cd ~/catkin_ws/src
git clone https://github.com/ros-industrial/abb_experimental.git
```

### VR Setup on Linux

```bash
# Install Monado OpenXR runtime
yay -S monado-git

# Install SteamVR (from Steam)
# Enable Proton compatibility in Steam settings

# Set Monado as active runtime
export XR_RUNTIME_JSON=/usr/share/openxr/1/openxr_monado.json

# Test VR
hello_xr  # OpenXR test application
```

### Python to TypeScript Conversion

```bash
# Initialize TypeScript project
mkdir my-mcp-server && cd my-mcp-server
pnpm init

# Install MCP dependencies
pnpm add @modelcontextprotocol/sdk zod

# Install dev dependencies
pnpm add -D typescript @types/node tsx

# Create tsconfig.json
tsc --init

# Convert Python logic to TypeScript
# Follow patterns in py-to-ts-deepresearch.md
```

## 🎮 Gaming & VR Details

### HP Reverb G2 Compatibility
- ✅ Display works via Monado
- ✅ Headset tracking (6DOF)
- ✅ External controller support (Valve Index)
- ⚠️ Native G2 controllers: Limited support
- ❌ Windows Mixed Reality features: Not available

### VR Performance Tips
- Use hybrid graphics (iGPU for display, dGPU for rendering)
- Configure PRIME offloading for optimal performance
- Lower SteamVR supersampling if performance issues occur
- Use Gamescope for better VR compositor integration

### Supported VR Games (via Proton)
- Beat Saber (via ALVR or Virtual Desktop)
- Half-Life: Alyx (with tweaks)
- Pavlov VR
- VRChat (limited)

## 🤖 Robotics Integration

### Current Capabilities
- ABB IRB 1600 simulation in Gazebo
- Forward/inverse kinematics via MoveIt
- Path planning and trajectory execution
- RViz visualization for debugging

### Future Enhancements
- **LLM Integration:** Natural language robot control
- **Computer Vision:** Object detection and tracking
- **Real Hardware:** IRC5 controller connection
- **Sensor Fusion:** Cameras, LIDAR, force sensors

### Common Robot Tasks
```python
# Example: Move robot to position (in simulation)
from moveit_commander import RobotCommander, PlanningSceneInterface
import rospy

rospy.init_node('robot_control')
robot = RobotCommander()
group = robot.get_group('manipulator')

# Set target position
group.set_pose_target([x, y, z, roll, pitch, yaw])
plan = group.plan()
group.execute(plan)
```

## 🔧 Development Tools

### MCP Server Architecture
```typescript
// Basic MCP server structure
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new Server({
  name: "my-osint-server",
  version: "1.0.0"
}, {
  capabilities: {
    tools: {}
  }
});

// Define tools
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [/* tool definitions */]
}));

// Start server
const transport = new StdioServerTransport();
await server.connect(transport);
```

### TypeScript Best Practices for MCP
- Use Zod for runtime schema validation
- Implement proper error handling with MCP error types
- Support both stdio and HTTP transports
- Add comprehensive logging for debugging
- Follow MCP protocol specifications strictly

## 📚 Learning Resources

### Robotics
- [ROS Wiki](http://wiki.ros.org/) - Official ROS documentation
- [Gazebo Tutorials](http://gazebosim.org/tutorials) - Simulation guides
- [ABB RobotStudio](https://new.abb.com/products/robotics/robotstudio) - Official ABB tools

### VR on Linux
- [Monado Documentation](https://monado.freedesktop.org/)
- [SteamVR on Linux](https://github.com/ValveSoftware/SteamVR-for-Linux)
- [r/linux_gaming VR Wiki](https://www.reddit.com/r/linux_gaming/wiki/vr)

### Development
- [MCP Documentation](https://modelcontextprotocol.io/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Zod Documentation](https://zod.dev/)

---

[← Back to Main README](../README.md)
