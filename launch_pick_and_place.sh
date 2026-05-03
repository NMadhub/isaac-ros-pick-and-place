#!/bin/bash
# =============================================================================
# Isaac ROS Pick & Place - Launch script (run INSIDE the container)
# Usage:  isaac-ros activate  →  then run this script
# Requires Isaac Sim to be running with the manipulator scene loaded
# =============================================================================

ISAAC_ROS_WS=${ISAAC_ROS_WS:-${HOME}/workspaces/isaac_ros-dev}

export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export ROS_DOMAIN_ID=${ROS_DOMAIN_ID:-0}
export ISAAC_ROS_MANIPULATION_WORKFLOW_CONFIG_DIR="${ISAAC_ROS_WS}/isaac_ros_manipulation_config"
export ISAAC_ROS_MANIPULATION_PICK_AND_PLACE_CONFIG_DIR="${ISAAC_ROS_WS}/isaac_ros_manipulation_config"

# Source workspace if built from source
if [ -f "${ISAAC_ROS_WS}/install/setup.bash" ]; then
    source ${ISAAC_ROS_WS}/install/setup.bash
fi

echo "================================================"
echo "  Isaac ROS Pick & Place Launcher"
echo "================================================"
echo "  ISAAC_ROS_WS        : $ISAAC_ROS_WS"
echo "  RMW_IMPLEMENTATION  : $RMW_IMPLEMENTATION"
echo "  ROS_DOMAIN_ID       : $ROS_DOMAIN_ID"
echo "  Config dir          : $ISAAC_ROS_MANIPULATION_WORKFLOW_CONFIG_DIR"
echo ""
echo "  Make sure Isaac Sim is running and the scene is loaded:"
echo "  https://omniverse-content-production.s3-us-west-2.amazonaws.com/Assets/Isaac/5.0/Isaac/Samples/ROS2/Scenario/isaac_manipulator_scene.usd"
echo ""
echo "  Press ENTER to launch, or Ctrl+C to abort..."
read

ros2 launch isaac_ros_manipulation_bringup workflows.launch.py \
    manipulator_workflow_config:=${ISAAC_ROS_MANIPULATION_WORKFLOW_CONFIG_DIR}/sim_launch_params.yaml
