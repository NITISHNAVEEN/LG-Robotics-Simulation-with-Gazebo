from launch import LaunchDescription

from launch_ros.actions import Node

def generate_launch_description():
    diff_drive_spawner = Node(
        package="controller_manager",
        executable="spawner",
        arguments=["joint_state_broadcaster"],
    )

    joint_broad_spawner = Node(
        package="controller_manager",
        executable="spawner",
        arguments=["joint_trajectory_controller"],
    )

    return LaunchDescription([
        diff_drive_spawner,
        joint_broad_spawner
    ])