#!/usr/bin/env python3
import rclpy
from rclpy.node import Node

from std_msgs.msg import Float32MultiArray
from geometry_msgs.msg import Twist

class JoystickToTwist(Node):
    """
    A ROS2 node that subscribes to joystick velocity commands and publishes them
    as Twist messages.
    """
    def __init__(self):
        """
        Initializes the node, creates a subscriber for joystick data,
        and a publisher for command velocity.
        """
        super().__init__('joystick_listener')

        # Declare parameters for max linear and angular speeds
        self.declare_parameter('max_linear_speed', 1.0)  # m/s
        self.declare_parameter('max_angular_speed', 2.0) # rad/s

        # Get the parameters
        self.max_linear_speed = self.get_parameter('max_linear_speed').get_parameter_value().double_value
        self.max_angular_speed = self.get_parameter('max_angular_speed').get_parameter_value().double_value

        self.get_logger().info(f"Using Max Linear Speed: {self.max_linear_speed} m/s")
        self.get_logger().info(f"Using Max Angular Speed: {self.max_angular_speed} rad/s")

        # Create the subscriber to '/joystick_vel'
        self.joystick_subscription = self.create_subscription(
            Float32MultiArray,
            '/joystick_vel',
            self.joystick_callback,
            10)
        # self.joystick_subscription  # prevent unused variable warning

        # Create the publisher to '/cmd_vel'
        self.cmd_vel_publisher = self.create_publisher(Twist, '/cmd_vel', 10)

    def joystick_callback(self, msg):
        """
        Callback function for the /joystick_vel topic.
        Processes the joystick data and publishes a Twist message.
        """
        # Ensure the message has at least two elements
        if len(msg.data) < 2:
            self.get_logger().warn('Received a Float32MultiArray with less than 2 elements. Ignoring.')
            return

        # Create a new Twist message
        twist_msg = Twist()

        # Map joystick data to Twist message
        # We assume:
        # msg.data[0] is for angular velocity (left/right, range -1.0 to 1.0)
        # msg.data[1] is for linear velocity (forward/backward, range -1.0 to 1.0)
        angular_input = msg.data[0]
        linear_input = msg.data[1]

        # Calculate the actual velocities
        # The joystick input (-1.0 to 1.0) is scaled by the max speeds
        twist_msg.linear.x = linear_input * self.max_linear_speed
        twist_msg.angular.z = -angular_input * self.max_angular_speed

        # The other fields are not used for a typical 2D robot
        twist_msg.linear.y = 0.0
        twist_msg.linear.z = 0.0
        twist_msg.angular.x = 0.0
        twist_msg.angular.y = 0.0

        # Publish the Twist message
        self.cmd_vel_publisher.publish(twist_msg)
        self.get_logger().info(
            f'Publishing to /cmd_vel: Linear X: {twist_msg.linear.x:.2f}, Angular Z: {twist_msg.angular.z:.2f}'
        )


def main(args=None):
    """
    Main function to initialize and run the ROS2 node.
    """
    rclpy.init(args=args)
    joystick_to_twist_node = JoystickToTwist()
    try:
        rclpy.spin(joystick_to_twist_node)
    except KeyboardInterrupt:
        pass
    finally:
        # Destroy the node explicitly
        # (optional - Done automatically when node is garbage collected)
        joystick_to_twist_node.destroy_node()
        rclpy.shutdown()

if __name__ == '__main__':
    main()