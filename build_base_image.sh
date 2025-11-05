!/bin/bash
set -e

# URL to download from
URL="https://raw.githubusercontent.com/eclipse-openj9/openj9/master/buildenv/docker/mkdocker.sh"

# Output file name
OUTPUT_FILE="mkdocker.sh"

# Download the file using wget
echo "Downloading $URL..."
wget "$URL" -O "$OUTPUT_FILE"

# Check if wget was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to download $URL"
    exit 1
else
    echo "Download successful. File saved as $OUTPUT_FILE"
fi
# Make the script executable
echo "Making $OUTPUT_FILE executable..."
chmod +x "$OUTPUT_FILE"

# Run mkdocker.sh with specified arguments
echo "Running $OUTPUT_FILE with parameters..."
bash "$OUTPUT_FILE" --tag=openj9 --dist=ubuntu --version=22 --gitcache=no --jdk=25 --build

# If the command was successful, print a message
echo "mkdocker.sh executed successfully."   


