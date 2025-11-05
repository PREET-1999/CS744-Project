#!/bin/bash
set -e
# --- Prevent running as root or with sudo ---
if [ "$EUID" -eq 0 ]; then
  echo "❌ ERROR: Do not run this script with sudo or as root."
  echo ""
  echo "➡️  Make sure your user is in the 'docker' group. To fix:"
  echo "    sudo usermod -aG docker \$USER"
  echo "    newgrp docker"
  echo ""
  echo "Then re-run this script *without* sudo."
  exit 1
fi
# Default values for volume mounting
DEFAULT_MOUNT_DIR=$(pwd)
USER_ID=$(id -u)
USER_NAME=$(whoami)

# Function to display usage message
usage() {
  echo "Usage: $0 [MOUNT_DIR]"
  echo "  MOUNT_DIR (optional): Directory to mount into the container at /home/$USER_NAME/CS744"
  echo "  If no MOUNT_DIR is specified, the current working directory will be used by default."
  echo ""
  echo "Example 1: Mount current directory (default)"
  echo "  $0"
  echo ""
  echo "Example 2: Mount custom directory"
  echo "  $0 /path/to/custom/directory"
}

# Check if user has provided a custom mount directory argument
MOUNT_DIR="${1:-$DEFAULT_MOUNT_DIR}"

# Display usage if the user provided '--help' or no arguments
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
  usage
  exit 0
fi

# Inform the user about the mount directory
echo "Mounting directory $MOUNT_DIR to /home/$USER_NAME/CS744 inside the container."

# Build the Docker image (myimg)
echo "Building Docker image 'myimg'..."
docker build --build-arg UID=$USER_ID --build-arg GID=$USER_ID --build-arg UNAME=$USER_NAME -t myimg .

# Remove old container if exists
if docker ps -a --format '{{.Names}}' | grep -q '^my_container$'; then
    echo "Removing old container"
    docker rm -f my_container
fi
# Run the Docker container in detached mode (-d) with volume mounted
echo "Running container in detached mode..."

# Mount the volume to /home/$USER_NAME/CS744 inside the container
docker run -d --name my_container \
  -v "$MOUNT_DIR:/home/$USER_NAME/CS744" \
  -it myimg /bin/bash

# # Exec into the container as the created user (not root)
# echo "Entering the container as user '$USER_NAME'..."
# docker exec -it -u $USER_NAME my_container /bin/bash
