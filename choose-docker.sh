#!/bin/bash

echo "Choose a robot to launch:"
echo "1) SO Arm 100 Interactive"
echo "2) SO Arm 100 Demo"
echo "3) Amigabot"
read -p "Enter your choice (1 or 2 or 3): " choice

xhost +local:docker

case $choice in
    1)
        echo "Launching SO Arm..."
        docker compose -f docker-compose-soarm-exp.yaml up
        ;;
    2)
        echo "Launching SO Arm..."
        docker compose -f docker-compose-soarm-demo.yaml up
        ;;
    3)
        echo "Launching Amigabot..."
        docker compose -f docker-compose-amigabot.yaml up
        ;;
    *)
        echo "Invalid choice."
        exit 1
        ;;
esac

