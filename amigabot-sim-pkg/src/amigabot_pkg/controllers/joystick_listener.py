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
        self.declare_parameter('max_linear_speed', 2.0)  # m/s
        self.declare_parameter('max_angular_speed', 2.0) # rad/s
        self.declare_parameter('max_linear_acceleration', 1.5) # m/s^2
        self.declare_parameter('max_angular_acceleration', 1.5) # rad/s^2
        self.declare_parameter('update_rate', 50.0) # Hz

        # Get the parameters
        self.max_linear_speed = 2.0
        self.max_angular_speed = 2.0
        self.max_linear_accel = 0.5
        self.max_angular_accel = 1.5
        self.update_rate = 50.0

        # Target velocities from the joystick
        self.target_linear_vel = 0.0
        self.target_angular_vel = 0.0
        # Current velocities being published (the filtered output)
        self.current_linear_vel = 0.0
        self.current_angular_vel = 0.0

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

        self.dt = 1.0 / self.update_rate
        self.timer = self.create_timer(self.dt, self.update_and_publish_twist)

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
        # twist_msg.linear.x = linear_input * self.max_linear_speed
        # twist_msg.angular.z = -angular_input * self.max_angular_speed
        self.target_linear_vel = linear_input * self.max_linear_speed
        self.target_angular_vel = -angular_input * self.max_angular_speed

    def update_and_publish_twist(self):
        """
        This function is called by the timer at a fixed rate.
        It calculates the new velocity based on acceleration limits
        and publishes the Twist message.
        """
        # Calculate the maximum change in velocity for this time step
        max_linear_change = self.max_linear_accel * self.dt
        max_angular_change = self.max_angular_accel * self.dt

        # Calculate the difference between target and current velocities
        linear_error = self.target_linear_vel - self.current_linear_vel
        angular_error = self.target_angular_vel - self.current_angular_vel

        # Clamp the change in velocity to the maximum allowed change
        linear_change = max(-max_linear_change, min(max_linear_change, linear_error))
        angular_change = max(-max_angular_change, min(max_angular_change, angular_error))

        # Update the current velocity
        self.current_linear_vel += linear_change
        self.current_angular_vel += angular_change

        # --- Create and publish the Twist message ---
        twist_msg = Twist()
        twist_msg.linear.x = self.current_linear_vel
        twist_msg.angular.z = self.current_angular_vel
        
        # Other fields are zero
        twist_msg.linear.y = 0.0
        twist_msg.linear.z = 0.0
        twist_msg.angular.x = 0.0
        twist_msg.angular.y = 0.0

        self.cmd_vel_publisher.publish(twist_msg)
        self.get_logger().debug(
            f'Target: [L:{self.target_linear_vel:.2f}, A:{self.target_angular_vel:.2f}] | '
            f'Current: [L:{self.current_linear_vel:.2f}, A:{self.current_angular_vel:.2f}]'
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