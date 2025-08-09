from flask_socketio import SocketIO, emit
import rclpy
from rclpy.node import Node
from sensor_msgs.msg import Image
from cv_bridge import CvBridge
import cv2
import threading
import time
from flask import Flask, Response, render_template, request
import os
import numpy as np # Import numpy for image operations

# Setup
NUM_SCREENS = 5
STREAM_WIDTH = 1080
STREAM_HEIGHT = 1920
TOTAL_WIDTH = STREAM_WIDTH * NUM_SCREENS

# --- Global state for controls ---
zoom_level = 1.0
show_overlay = True
zoom_lock = threading.Lock()
overlay_lock = threading.Lock()

# --- Global variables for the overlay image ---
logo_image = None
about_page = None
overlay_mask = None

# Create Flask apps and SocketIO instance
apps = [Flask(f'screen{i+1}', template_folder='templates') for i in range(NUM_SCREENS)]
control_app = Flask('control_app')
control_app.config['SECRET_KEY'] = 'secret!' # Required for SocketIO
socketio = SocketIO(control_app)
frames = [None] * NUM_SCREENS

# ROS2 node for subscribing to the camera feed
class CameraSubscriber(Node):
    def __init__(self):
        super().__init__('camera_stream_splitter')
        self.bridge = CvBridge()
        self.subscription = self.create_subscription(
            Image,
            '/camera/image_raw',
            self.image_callback,
            10
        )

    def image_callback(self, msg):
        global frames, zoom_level
        try:
            source_img = self.bridge.imgmsg_to_cv2(msg, desired_encoding='bgr8')
            
            with zoom_lock:
                current_zoom = zoom_level

            if current_zoom > 1.0:
                crop_width = int(source_img.shape[1] / current_zoom)
                crop_height = int(source_img.shape[0] / current_zoom)
                start_x = (source_img.shape[1] - crop_width) // 2
                start_y = (source_img.shape[0] - crop_height) // 2
                zoomed_section = source_img[start_y:start_y + crop_height, start_x:start_x + crop_width]
                img = cv2.resize(zoomed_section, (TOTAL_WIDTH, STREAM_HEIGHT), interpolation=cv2.INTER_LINEAR)
            else:
                if source_img.shape[1] != TOTAL_WIDTH or source_img.shape[0] != STREAM_HEIGHT:
                    img = cv2.resize(source_img, (TOTAL_WIDTH, STREAM_HEIGHT))
                else:
                    img = source_img

            for i in range(NUM_SCREENS):
                start = i * STREAM_WIDTH
                end = (i + 1) * STREAM_WIDTH
                frames[i] = img[:, start:end]
        except Exception as e:
            self.get_logger().error(f"Image callback failed: {e}")

# --- MODIFIED: Generator to include image overlay ---
def generate(index):
    global show_overlay, logo_image, about_page, overlay_mask
    while True:
        frame = frames[index]
        if frame is None:
            time.sleep(0.01)
            continue

        # Make a copy to avoid modifying the original frame in the shared list
        output_frame = frame.copy()

        if index == 0:

            # Check if the overlay should be applied
            with overlay_lock:
                apply_overlay = show_overlay

            if apply_overlay and logo_image is not None:
                try:
                    # Define the region of interest (top-left corner)
                    h, w, _ = logo_image.shape
                    roi = output_frame[10:h+10, 10:w+10] # 10px padding

                    # Black-out the area of the logo in the background
                    img1_bg = cv2.bitwise_and(roi, roi, mask=cv2.bitwise_not(overlay_mask))
                    
                    # Take only the region of the logo from the logo image.
                    img2_fg = cv2.bitwise_and(logo_image, logo_image, mask=overlay_mask)

                    # Put logo in ROI and modify the main image
                    dst = cv2.add(img1_bg, img2_fg)
                    output_frame[100:h+100, 100:w+100] = dst
                except Exception as e:
                    # This can happen if the overlay is larger than the frame, etc.
                    print(f"Could not apply overlay: {e}")


        ret, buffer = cv2.imencode('.jpg', output_frame, [int(cv2.IMWRITE_JPEG_QUALITY), 60])
        if not ret:
            continue
        yield (b'--frame\r\nContent-Type: image/jpeg\r\n\r\n' +
               buffer.tobytes() + b'\r\n')
        time.sleep(1 / 15)  # 15 FPS

# Register routes for each Flask app
def create_routes(app, index):
    @app.route('/')
    def index_page():
        return render_template('index.html')

    @app.route('/video_feed')
    def video_feed():
        return Response(generate(index),
                        mimetype='multipart/x-mixed-replace; boundary=frame',
                        headers={
                            'Cache-Control': 'no-cache, no-store, must-revalidate',
                            'Pragma': 'no-cache',
                            'Expires': '0',
                            'Connection': 'keep-alive'
                        })

# --- WebSocket Handlers ---
@socketio.on('set_zoom')
def handle_zoom_event(json):
    global zoom_level
    try:
        level = float(json.get('level', 1.0))
        if level >= 1.0:
            with zoom_lock:
                zoom_level = level
            emit('zoom_updated', {'level': level}, broadcast=True)
            print(f"WebSocket: Zoom level set to {level}")
        else:
            emit('error', {'message': 'Zoom level must be >= 1.0'})
    except (ValueError, TypeError):
        emit('error', {'message': 'Invalid zoom level received.'})

# --- NEW: WebSocket handler for image overlay ---
@socketio.on('toggle_overlay')
def handle_overlay_event(json):
    global show_overlay
    try:
        show = bool(json.get('show', False))
        with overlay_lock:
            show_overlay = show
        emit('overlay_updated', {'show': show}, broadcast=True)
        status = "shown" if show else "hidden"
        print(f"WebSocket: Overlay is now {status}")
    except Exception as e:
        emit('error', {'message': f'Invalid overlay command: {e}'})

def run_socketio_server(app, port):
    socketio.run(app, host='0.0.0.0', port=port, allow_unsafe_werkzeug=True)

def run_flask(app, port):
    app.run(host='0.0.0.0', port=port, debug=False, use_reloader=False)

def ros_spin():
    rclpy.init()
    node = CameraSubscriber()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    # --- NEW: Load and prepare the overlay image once at startup ---
    try:
        logo_path = 'RoboLGlogo.png'
        # Load with alpha channel
        logo_rgba = cv2.imread(logo_path, cv2.IMREAD_UNCHANGED)
        if logo_rgba is None:
            raise FileNotFoundError(f"Could not find {logo_path}")
        
        # Resize logo
        logo_resized = cv2.resize(logo_rgba, (795, 875), interpolation=cv2.INTER_AREA)

        # Split the alpha channel to create a mask
        b, g, r, a = cv2.split(logo_rgba)
        logo_image = cv2.merge((b, g, r))
        overlay_mask = a # The alpha channel is our mask
        print(f"✅ Overlay logo '{logo_path}' loaded successfully.")

    except Exception as e:
        print(f"⚠️  Warning: Could not load overlay logo. Overlay will be disabled. Error: {e}")
    # --- END ---

    ports = [8081 + i for i in range(NUM_SCREENS)]
    control_port = 8080

    for i in range(NUM_SCREENS):
        create_routes(apps[i], i)

    threading.Thread(target=ros_spin, daemon=True).start()
    for i in range(NUM_SCREENS):
        threading.Thread(target=run_flask, args=(apps[i], ports[i]), daemon=True).start()
    
    threading.Thread(target=run_socketio_server, args=(control_app, control_port), daemon=True).start()
    
    print(f"Video streams running on ports 8081-8085.")
    print(f"Control server running on port {control_port}.")

    while True:
        time.sleep(1)