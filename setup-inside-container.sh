#!/bin/bash
set -e  # Exit on any error

# Base directory (directory where this script resides)
BASE_DIR="$(realpath "$(dirname "$0")")"
echo "Base directory: $BASE_DIR"

# Ensure working directory exists
mkdir -p "$BASE_DIR/jdk/jdk25"
cd "$BASE_DIR/jdk/jdk25"

# Function to setup a version of OpenJ9
setup_openj9() {
    local dir_name="$1"
    local openj9_branch="$2"
    local omr_branch="$3"

    echo "Setting up $dir_name ..."
    mkdir -p "$dir_name"
    cd "$dir_name"

    # Clone base JDK repo
    git clone https://github.com/ibmruntimes/openj9-openjdk-jdk25.git
    cd openj9-openjdk-jdk25

    # Run get_source.sh with specified branches
    bash get_source.sh \
        -openj9-repo=https://github.com/PREET-1999/CS744-Project-Openj9.git \
        -openj9-branch="$openj9_branch" \
        -omr-repo=https://github.com/PREET-1999/CS744-Project-OMR.git \
        -omr-branch="$omr_branch"

    # Return to jdk8 parent directory
    cd "$BASE_DIR/jdk/jdk25"
}

# === Step 1: Setup ===
setup_openj9 "openj9" "master" "openj9"

echo "All OpenJ9 setups completed."

# # === Step 2: Build the 'base' JVM ===
# echo "Starting build for openj9-base ..."

# BASE_JVM_DIR="$BASE_DIR/jdk/jdk25/openj9-base/openj9-openjdk-jdk25"
# cd "$BASE_JVM_DIR"

# # Clean previous build
# make clean || true   # ignore error if nothing was built

# # Set compiler flags
# export CFLAGS="-g -gdwarf-4 -Wno-error=maybe-uninitialized"
# export CXXFLAGS="-g -gdwarf-4 -Wno-error=maybe-uninitialized"

# # Configure build
# bash configure \
#   --with-cmake \
#   --with-boot-jdk=/home/jenkins/bootjdks/jdk8 \
#   --with-native-debug-symbols=internal \
#   --enable-jitserver

# # Compile
# make all

# echo "✅ Base JVM build completed successfully!"


build_openj9_variant() {
  local variant="$1"
  echo "Starting build for $variant ..."
  local build_dir="$BASE_DIR/jdk/jdk25/$variant/openj9-openjdk-jdk25"
  cd "$build_dir"

 # make clean || true

  export CFLAGS="-g -gdwarf-4 -Wno-error=maybe-uninitialized"
  export CXXFLAGS="-g -gdwarf-4 -Wno-error=maybe-uninitialized"

  bash configure \
    --with-boot-jdk=/home/jenkins/bootjdks/jdk25 \
    --with-native-debug-symbols=internal \
    --enable-jitserver

  make all

  echo "✅ $variant JVM build completed successfully!"
  echo
}

for variant in openj9; do
  build_openj9_variant "$variant"
done

for variant in openj9; do
  echo "🔍 Verifying Java version for: $variant"
  "$BASE_DIR/jdk/jdk25/$variant/openj9-openjdk-jdk25/build/linux-x86_64-server-release/images/jdk/bin/java" -version
  echo
done

export JAVA_HOME="$BASE_DIR/jdk/jdk25/openj9/openj9-openjdk-jdk25/build/linux-x86_64-server-release/images/jdk"
export PATH="$JAVA_HOME/bin:$PATH"