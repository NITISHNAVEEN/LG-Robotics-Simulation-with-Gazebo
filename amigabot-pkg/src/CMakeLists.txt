cmake_minimum_required(VERSION 3.8)
project(amigabot_pkg)

find_package(ament_cmake REQUIRED)
find_package(urdf REQUIRED)

install(
  DIRECTORY meshes urdf launch models worlds config controllers
  DESTINATION share/${PROJECT_NAME}
)

install(PROGRAMS
  controllers/joystick_listener.py
  DESTINATION lib/${PROJECT_NAME}
)

ament_package()
