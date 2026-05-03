# Isaac ROS Pick & Place — Isaac Sim Setup

This workspace sets up the NVIDIA Isaac ROS Multi-Object Pick & Place workflow
for testing in Isaac Sim 5.0 on your 2x L40S system.

## Quick Start

### Step 1 — Enter the Isaac ROS container (one terminal)
```bash
cd ~/workspaces/isaac_ros-dev
isaac-ros activate
```

### Step 2 — Run one-time setup (INSIDE the container, first time only)
```bash
cd ~/workspaces/isaac_ros-dev
./setup_pick_and_place.sh
```
> This takes ~20–30 mins (downloads perception models: FoundationPose, SyntheticaDETR, ESS, SAM).

### Step 3 — Launch Isaac Sim
```bash
~/isaacsim/_build/linux-x86_64/release/isaac-sim.sh
```
Load this scene URL in Isaac Sim (File → Open URL):
```
https://omniverse-content-production.s3-us-west-2.amazonaws.com/Assets/Isaac/5.0/Isaac/Samples/ROS2/Scenario/isaac_manipulator_scene.usd
```
Hit **Play** ▶ to start the simulation.

### Step 4 — Launch the workflow (INSIDE the container)
```bash
cd ~/workspaces/isaac_ros-dev
./launch_pick_and_place.sh
```

### Step 5 — Trigger a pick and place (new terminal, INSIDE the container)
```bash
cd ~/workspaces/isaac_ros-dev
# Single bin mode (all objects to one drop location):
./trigger_pick_and_place.sh single

# Multi-bin mode (sort objects to different locations):
./trigger_pick_and_place.sh multi
```

---

## Workspace Layout

```
~/workspaces/isaac_ros-dev/
├── src/
│   ├── isaac_ros_manipulation/       # Isaac ROS Manipulation (release-4.4)
│   ├── ros2_robotiq_gripper/         # Robotiq gripper driver
│   ├── serial/                       # Serial comm lib (gripper dependency)
│   └── topic_based_ros2_control/     # ROS 2 control bridge for Isaac Sim
├── isaac_ros_manipulation_config/
│   ├── sim_launch_params.yaml        # Workflow config (sim-specific)
│   ├── multi_object_pick_and_place_behavior_tree_params.yaml
│   └── multi_object_pick_and_place_blackboard_params.yaml
├── setup_pick_and_place.sh           # One-time setup (run inside container)
├── launch_pick_and_place.sh          # Launch workflow (run inside container)
└── trigger_pick_and_place.sh         # Trigger action goal (run inside container)
```

---

## Isaac Sim Scene Physics Optimization

For better performance (after loading the scene, before hitting Play):
1. Select `/World/PhysicsScene` in the Stage panel
2. In Properties, **disable** `Enable GPU dynamics` (CPU physics is faster for single robot)
3. Change `Time Steps Per Second` to `60`
4. Hit **Play**

---

## Objects in the Scene
- **Mac & Cheese Box** — SyntheticaDETR class ID `22`
- **Soup Can** — SyntheticaDETR class ID `3`

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `cluster unreachable` in helm/kubectl | Run `export KUBECONFIG=/etc/kubernetes/admin.conf` |
| `kubectl` uses wrong server | Run `export KUBECONFIG=/etc/kubernetes/admin.conf` |
| Isaac Sim 5.0 vs 5.1 scene mismatch | Use the `5.0` scene URL above (not `5.1`) |
| Gripper in bad state in sim | `ros2 action send_goal /robotiq_gripper_controller/gripper_cmd control_msgs/action/GripperCommand "{command: {position: 0.0, max_effort: 0.0}}"` |
| Robot doesn't move | Check for ghost voxels or pose estimation errors in RViz |
