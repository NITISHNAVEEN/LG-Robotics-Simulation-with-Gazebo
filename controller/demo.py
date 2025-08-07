#!/usr/bin/env python3
import math
import numpy as np
import rclpy
from rclpy.node import Node
from trajectory_msgs.msg import JointTrajectory, JointTrajectoryPoint
from sensor_msgs.msg import JointState
from std_msgs.msg import Bool

import time
import threading

class DemoController(Node):
    def __init__(self):
        super().__init__('demo_controller')
        
        
        self.joint_names = ["Shoulder_Rotation", "Shoulder_Pitch", "Elbow", "Wrist_Pitch", "Wrist_Roll", "Gripper"]
        
        self.goal_tolerances = [0.05, 0.05, 0.05, 0.05, 0.05, 0.1]

        self.current_joint_positions = []
        self.demo_running = False
        self.lock = threading.Lock()


        self.joint_publisher = self.create_publisher(JointTrajectory, '/joint_trajectory_controller/joint_trajectory', 10)
        self.joint_subscriber = self.create_subscription(JointState, '/joint_states', self.joint_state_callback, 10)
        self.bool_subscriber = self.create_subscription(Bool, '/order', self.bool_callback, 10)
        
        self.get_logger().info('Demo Controller Node is ready.')

    def joint_state_callback(self, msg):
        
        with self.lock:
            joint_positions_map = {name: pos for name, pos in zip(msg.name, msg.position)}
            ordered_positions = []
            for name in self.joint_names:
                ordered_positions.append(joint_positions_map.get(name, 0.0))
            self.current_joint_positions = ordered_positions

    def bool_callback(self, msg):
        
        if msg.data and not self.demo_running:
            self.get_logger().info("Received 'True' on /order topic. Starting demo sequence.")
            demo_thread = threading.Thread(target=self.perform_demo)
            demo_thread.start()
        elif not msg.data:
            pass

    def send_joint_command(self, positions):

        if len(positions) != len(self.joint_names):
            self.get_logger().error(f"Command length mismatch: Expected {len(self.joint_names)}, got {len(positions)}")
            return

        msg = JointTrajectory()
        msg.joint_names = self.joint_names

        point = JointTrajectoryPoint()
        point.positions = [float(p) for p in positions]
        point.time_from_start.sec = 2
        point.time_from_start.nanosec = 0

        msg.points.append(point)
        self.joint_publisher.publish(msg)
        self.get_logger().info(f"Published command: {point.positions}")

    def is_goal_reached(self, goal_positions):
        
        with self.lock:
            if not self.current_joint_positions:
                self.get_logger().warn("Cannot check goal, current joint positions not yet received.")
                return False
            
            if len(goal_positions) != len(self.current_joint_positions):
                return False

            for goal, current, tolerance in zip(goal_positions, self.current_joint_positions, self.goal_tolerances):
                if abs(goal - current) > tolerance:
                    return False 
            
            return True

    def perform_demo(self):
        
        self.demo_running = True
        
        waypoints = [
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.6],
            [0.23, 0.0, -0.89, 0.0, 0.0, 0.6],
            [0.23, 0.90, -0.89, -0.1, 0.0, 0.6],
            [0.23, 0.90, -0.89, -0.1, 0.0, 0.22],
            [0.23, 0.20, -0.89, 0.0, 0.0, 0.22],
            [-0.5, 0.43, -1.1, -0.89, 0.0, 0.22],
            [-0.5, 0.43, -1.1, -0.89, 0.0, 0.87],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        ]

        try:
            while not self.current_joint_positions and rclpy.ok():
                self.get_logger().info("Waiting for initial joint states from /joint_states...", throttle_duration_sec=2)
                time.sleep(0.5)

            for i, waypoint in enumerate(waypoints):
                if not rclpy.ok(): break

                self.get_logger().info(f"--- Moving to Waypoint {i+1}/{len(waypoints)} ---")
                self.send_joint_command(waypoint)

                while not self.is_goal_reached(waypoint):
                    if not rclpy.ok():
                        break 
                    time.sleep(0.1)  
                
                
                if rclpy.ok():
                    self.get_logger().info(f"Waypoint {i+1} reached.")
                    time.sleep(1.5) 

        except Exception as e:
            self.get_logger().error(f"An error occurred during the demo sequence: {e}")
        finally:
            self.get_logger().info("Demo sequence finished.")
            self.demo_running = False

def main(args=None):
    rclpy.init(args=args)
    demo_node = DemoController()
    try:
        rclpy.spin(demo_node)
    except KeyboardInterrupt:
        pass
    finally:
        demo_node.destroy_node()
        rclpy.shutdown()

if __name__ == '__main__':
    main()