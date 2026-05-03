#!/bin/bash
# =============================================================================
# Isaac ROS Pick & Place - One-time setup script (run INSIDE the container)
# Run this after: isaac-ros activate
# =============================================================================
set -e

ISAAC_ROS_WS=${ISAAC_ROS_WS:-${HOME}/workspaces/isaac_ros-dev}
echo "[setup] ISAAC_ROS_WS=$ISAAC_ROS_WS"

# ── 0. Upgrade Isaac ROS apt repo from release-4.0 → release-4.4 ──────────
echo "[0/8] Updating Isaac ROS apt source to release-4.4..."
ISAAC_KEY="/usr/share/keyrings/nvidia-isaac-ros.gpg"
ISAAC_LIST="/etc/apt/sources.list.d/nvidia-isaac-ros.list"
NEW_SOURCE="deb [signed-by=${ISAAC_KEY}] https://isaac.download.nvidia.com/isaac-ros/release-4.4 noble main"

# Only update if not already on 4.4
if ! grep -q "release-4.4" "${ISAAC_LIST}" 2>/dev/null; then
    echo "${NEW_SOURCE}" | sudo tee "${ISAAC_LIST}" > /dev/null
    echo "Switched to release-4.4"
else
    echo "Already on release-4.4"
fi

# ── 1. Install Cyclone DDS ─────────────────────────────────────────────────
echo "[1/8] Installing Cyclone DDS..."
sudo apt-get update -o Dir::Etc::sourcelist="${ISAAC_LIST}" 2>/dev/null || sudo apt-get update || true
sudo apt-get install -y ros-jazzy-rmw-cyclonedds-cpp python3-pip python3-git
pip install --break-system-packages pyvers==0.2.2

# ── 2. Install Isaac ROS Manipulation binary package ──────────────────────
echo "[2/8] Installing Isaac ROS Manipulation packages..."
sudo apt-get update || true
sudo apt-get install -y ros-jazzy-isaac-ros-manipulation-bringup

# ── 3. Install rosdep dependencies for source packages ────────────────────
echo "[3/8] Installing rosdep dependencies..."
rosdep update
rosdep install --from-paths \
    ${ISAAC_ROS_WS}/src/ros2_robotiq_gripper \
    ${ISAAC_ROS_WS}/src/serial \
    ${ISAAC_ROS_WS}/src/topic_based_ros2_control \
    --ignore-src -y

# ── 4. Install segment_anything (required for perception models) ───────────
echo "[4/8] Installing segment_anything..."
pip install --no-deps --break-system-packages \
    git+https://github.com/facebookresearch/segment-anything.git

# ── 5. Build source packages ───────────────────────────────────────────────
echo "[5/8] Building source packages (gripper, serial, topic_based_ros2_control)..."
cd ${ISAAC_ROS_WS}
colcon build --symlink-install \
    --packages-select-regex "robotiq*" serial topic_based_ros2_control \
    --cmake-args "-DBUILD_TESTING=OFF"
source install/setup.bash

# ── 6. Accept EULAs and download perception models ────────────────────────
echo "[6/8] Downloading perception models (this takes ~15-20 mins)..."
export ISAAC_ROS_ACCEPT_EULA=1
export MANIPULATOR_INSTALL_ASSETS=1
export FOUNDATIONSTEREO_MODEL_RES=low_res
ros2 run isaac_ros_manipulation_asset_bringup setup_perception_models.py --models all

# ── 7. Copy sim config files ───────────────────────────────────────────────
echo "[7/8] Copying sim config files..."
mkdir -p ${ISAAC_ROS_WS}/isaac_ros_manipulation_config

cp $(ros2 pkg prefix --share isaac_ros_manipulation_bringup)/params/sim_launch_params.yaml \
   ${ISAAC_ROS_WS}/isaac_ros_manipulation_config/sim_launch_params.yaml

cp $(ros2 pkg prefix --share isaac_ros_manipulation_pick_and_place)/params/multi_object_pick_and_place_behavior_tree_params.yaml \
   ${ISAAC_ROS_WS}/isaac_ros_manipulation_config/

cp $(ros2 pkg prefix --share isaac_ros_manipulation_pick_and_place)/params/multi_object_pick_and_place_blackboard_params.yaml \
   ${ISAAC_ROS_WS}/isaac_ros_manipulation_config/

# ── 8. Patch sim_launch_params.yaml for Isaac Sim 5.0 ─────────────────────
echo "[8/8] Setting up sim config for Isaac Sim..."
# Apply sim-specific overrides (camera frame for Isaac Sim)
python3 - << 'EOF'
import yaml, os
config_path = os.path.expandvars("${ISAAC_ROS_WS}/isaac_ros_manipulation_config/sim_launch_params.yaml")
with open(config_path, 'r') as f:
    cfg = yaml.safe_load(f)

cfg['workflow_type'] = 'PICK_AND_PLACE'
cfg['segmentation_type'] = 'NONE'
cfg['object_detection_type'] = 'RTDETR'
cfg['enable_nvblox'] = 'false'
cfg['use_ground_truth_pose_in_sim'] = 'false'

with open(config_path, 'w') as f:
    yaml.dump(cfg, f, default_flow_style=False)
print(f"Updated {config_path}")
EOF

echo ""
echo "============================================================"
echo "  Setup complete!"
echo "  Next: run ./launch_pick_and_place.sh to start the workflow"
echo "============================================================"
