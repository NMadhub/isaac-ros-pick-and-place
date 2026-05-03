#!/bin/bash
# =============================================================================
# Trigger a pick and place action (run INSIDE the container, after launch)
# =============================================================================

export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export ROS_DOMAIN_ID=${ROS_DOMAIN_ID:-0}

MODE=${1:-single}  # "single" or "multi"

echo "Triggering pick and place in $MODE bin mode..."

if [ "$MODE" = "single" ]; then
    # Single bin: all objects to one location
    ros2 action send_goal --feedback /multi_object_pick_and_place \
        isaac_ros_manipulation_interfaces/action/MultiObjectPickAndPlace \
        '{target_poses: {header: {frame_id: "base_link"}, poses: [{position: {x: -0.25, y: -0.35, z: 0.50}, orientation: {w: 0.017994, x: -0.677772, y: 0.734752, z: 0.020993}}]}, class_ids: [], mode: 0}'
else
    # Multi-bin: sort objects to different locations
    ros2 action send_goal --feedback /multi_object_pick_and_place \
        isaac_ros_manipulation_interfaces/action/MultiObjectPickAndPlace \
        '{target_poses: {header: {frame_id: "base_link"}, poses: [{position: {x: -0.25, y: -0.35, z: 0.50}, orientation: {w: 0.017994, x: -0.677772, y: 0.734752, z: 0.020993}}, {position: {x: 0.25, y: -0.35, z: 0.50}, orientation: {w: 0.017994, x: -0.677772, y: 0.734752, z: 0.020993}}]}, class_ids: [], mode: 1}'
fi
