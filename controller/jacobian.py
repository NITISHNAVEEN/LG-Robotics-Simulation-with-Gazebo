#!/usr/bin/env python3
import math
import numpy as np
import rclpy
from rclpy.node import Node
from trajectory_msgs.msg import JointTrajectory, JointTrajectoryPoint
from sensor_msgs.msg import JointState
from std_msgs.msg import Float32MultiArray

L1 = 0.116
L2 = 0.135
L3 = 0.1
H = 0.126

class ArmController(Node):
    def __init__(self):
        super().__init__('jacobian_matrix')
        self.alpha = [0.0]*6
        self.theta = [0.0]*6
        self.K = 0.4   # Proportional gain
        self.dt = 0.5 # Time step in seconds
        self.vx = 0.0
        self.vz = 0.0
        self.vy = 0.0
        self.gripper = 0.0
        self.joint_publisher = self.create_publisher(JointTrajectory, '/joint_trajectory_controller/joint_trajectory', 10)
        self.joint_names = ["Shoulder_Rotation", "Shoulder_Pitch", "Elbow", "Wrist_Pitch", "Wrist_Roll", "Gripper"]
        self.joint_subscriber = self.create_subscription(JointState, '/joint_states', self.joint_state_callback, 10)  
        self.joystick_subscriber = self.create_subscription(Float32MultiArray, '/joystick_jacobian', self.joystick_callback, 10)
        self.timer = self.create_timer(self.dt, self.control_loop)
    
    def joint_state_callback(self, msg):
        self.alpha[1] = msg.position[1] # shoulder pitch
        self.alpha[2] = msg.position[2] # elbow
        self.alpha[3] = msg.position[3] # wrist pitch
        self.theta[1] = msg.position[1]
        self.theta[2] = msg.position[2] + 1.57 
        self.theta[3] = msg.position[3] +1.57 

    def publish_joint_angles(self, command0, command1, command2, command3, command4):
        try:
            # alpha0, alpha1, alpha2, alpha3 = get_angles(x, y, z)
            command2 = command2 - 1.57
            command3 = command3 - 1.57
            # if all(-1.58 <= alpha <= 1.58 for alpha in [command0, command1, command2, command3]): # all commands are within the range
            msg = JointTrajectory()
            msg.joint_names = self.joint_names

            point = JointTrajectoryPoint()
            point.positions = [command0, command1, command2, command3, 0.0, command4]  # wrist_roll and gripper fixed
            point.time_from_start.sec = 1
            point.time_from_start.nanosec = 0

            msg.points.append(point)

            self.joint_publisher.publish(msg)
            # self.get_logger().info(f"Published: {point.positions}")
            # else:
            #     raise Exception("Point out of Reach")
            
        except ValueError as e:
            self.get_logger().warn(f"IK Error: {e}")

    def joystick_callback(self, msg):
        if len(msg.data) >= 2:
            self.vy = msg.data[0]
            self.vx = msg.data[1]
            self.vz = msg.data[2]
            self.gripper = msg.data[3]
            self.get_logger().info(f"Joystick updated: vx={self.vx}, vz={self.vz}")
    
    def calculate_jacobian(self):
        t1, t2, t3 = self.theta[1], self.theta[2], self.theta[3]
        s1 = math.sin(t1)
        c1 = math.cos(t1)
        s12 = math.sin(t1 + t2)
        c12 = math.cos(t1 + t2)
        s123 = math.sin(t1 + t2 + t3)
        c123 = math.cos(t1 + t2 + t3)

        # Derivatives of x (horizontal) and z (vertical)
        j11 = L1 * c1 + L2 * c12 + L3 * c123
        j12 = L2 * c12 + L3 * c123
        j13 = L3 * c123

        j21 = -L1 * s1 - L2 * s12 - L3 * s123
        j22 = -L2 * s12 - L3 * s123
        j23 = -L3 * s123

        J = np.array([
            [j11, j12, j13],
            [j21, j22, j23]
        ])
        return J
    
    def control_loop(self):

        vy, vx, vz, gripper = self.vy, self.vx, self.vz, self.gripper
        # print((vx,vz))
        end_effector_velocity = np.array([[vx], [vz]])

        J = self.calculate_jacobian()

        # Compute pseudoinverse of the Jacobian
        J_pinv = np.linalg.pinv(J)

        # Compute joint velocities
        joint_velocities = J_pinv @ end_effector_velocity

        # Compute new joint angles
        delta_thetas = joint_velocities.flatten() * self.K * 0.1
        command1 = self.theta[1] + delta_thetas[0]
        command2 = self.theta[2] + delta_thetas[1]
        command3 = self.theta[3] + delta_thetas[2]

        # Optional: Clamp joint angles if needed
        # new_thetas = np.clip(new_thetas, -np.pi, np.pi)

        # Send command
        self.publish_joint_angles(vy, command1, command2, command3, gripper)

def main():
    rclpy.init()
    arm_node = ArmController()
    try:
        rclpy.spin(arm_node)
    except KeyboardInterrupt:
        pass
    finally:
        arm_node.destroy_node()
        rclpy.shutdown()
# sensor_msgs.msg.JointState(header=std_msgs.msg.Header(stamp=builtin_interfaces.msg.Time(sec=526, nanosec=102000000), frame_id=''), name=['Shoulder_Rotation', 'Shoulder_Pitch', 'Elbow', 'Wrist_Pitch', 'Wrist_Roll', 'Gripper'], position=[-3.144745975002159e-19, 3.698921121934369e-12, 5.910765033070038e-12, 1.1185694482722332e-14, -6.258985350867907e-19, 2.8948087461876576e-13], velocity=[2.5900944528612396e-17, -1.4189603669284107e-16, 6.37513561400373e-17, -1.2444181460656788e-16, 1.177554429226488e-17, 4.233113741984919e-17], effort=[0.0, 0.0, 0.0, 0.0, 0.0, 0.0]) 

if __name__ == '__main__':
    main()