cmake_minimum_required(VERSION 3.8)
project(lg_arm_control)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# find dependencies
find_package(ament_cmake REQUIRED)

install(
  DIRECTORY urdf launch config assets worlds controller
  DESTINATION share/${PROJECT_NAME}
)

install(PROGRAMS
  controller/jacobian.py
  DESTINATION lib/${PROJECT_NAME}
)

ament_package()
