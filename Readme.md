# JITServer Load Testing and Performance Evaluation

This project is focused on conducting load testing and performance evaluation for the **OpenJ9 JITServer**, a distributed runtime system where Just-In-Time (JIT) compilation is offloaded to a server. The goal is to analyze and optimize the client–server setup by evaluating various workloads .It introduces an enhancement to demonstrate dual request paths(Memory and Disk) on top of which performance would be evaluated


This project extends the OpenJ9 JITServer with a new runtime option(to support requests going to disk):
```bash
jitserver -XX:+JITServerSaveCompilationsToDisk
```

When enabled, the JITServer saves the names of compiled methods to a file after each successful compilation.

---

## Pre-requisites

Before running the setup or build scripts, make sure the following requirements are met:

1. **Docker Installed**
   - Ensure that Docker is properly installed and running on your system.
   - You can verify this by running:
     ```bash
     docker --version
     ```
   - If Docker requires `sudo`, add your user to the Docker group:
     ```bash
     sudo usermod -aG docker $USER
     newgrp docker
     ```

2. **Sufficient Disk Space**
   - Make sure you have **at least 4 GB of free space** available.
   - This is required for building Docker images, cloning repositories, and storing build artifacts.

---
---

## Installation & Usage

Follow the steps below to build and verify the base Docker image for the OpenJ9 JITServer setup.

### 1️ Build the Base Image

Run the following command from the project root directory:

```bash
bash build_base_image.sh
``` 

### 2️ Build Custom Image and Run Container

Run the following script to create a custom Docker image and start a container:

```bash
bash build_custom_image_and_run_container.sh
```

Now verify you would be inside the container in CS744 working directory as NON-ROOT user.

### 3 Setup Client-Server

Run the following script to create a client-server setup which will enable to run the server and connect via clients to it later: (This step will take time)

```bash
bash setup-inside-container.sh
```

### 4 Update the ~/.bashrc to set ENV variables
```bash
source ~/.bashrc
```

### 5 Test JITServer Client-Server Setup

To test the client-server setup, open **two terminal sessions** inside the container:

**Terminal 1:** Start the server(JITServer:server) by running:
```bash
jitserver
```

If you are able to see the output
**CS-744 JITServer is ready to accept incoming requests**

The Server is successfully able to accept requests


**Terminal 2:** Start the client(JITServer:client) by running:
```bash
java "-XX:+UseJITServer" -version
```
(you could use any other java class, for testing Ive used -version)

If you would like to test the disk-write path (extended functionality), start the server with the new flag:
```bash
jitserver -XX:+JITServerSaveCompilationsToDisk
```
After each successful compilation, the server writes the compiled method names to a file (***compiled_methods.txt*** relative to cwd) on disk.

### Note : Repositories Used

This project uses two primary repositories:

1. **[OpenJ9](<https://github.com/PREET-1999/CS744-Project-Openj9>)**  
   - The main Just-In-Time (JIT) compiler and runtime implementation used in this project.  
   - Contains the core JIT code where modifications and file read/write operations were added.  

2. **[OMR](<https://github.com/PREET-1999/CS744-Project-OMR>)**  
   - A foundational library that provides the compiler and runtime infrastructure used by OpenJ9.  
   - OpenJ9 depends on OMR for low-level utilities, compiler technology, and platform abstraction layers.  

Both repositories are tightly coupled **OpenJ9 builds on top of OMR**.
