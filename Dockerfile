# # Use a base image of Ubuntu 22.04 LTS (Jammy)
# FROM ubuntu:22.04

# # Define build arguments
# ARG UNAME=testuser
# ARG UID=1000
# ARG GID=1000

# # Create a group with the specified GID
# RUN groupadd -g $GID -o $UNAME

# # Create a user with the specified UID and GID
# RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

# # Switch to the new user
# USER $UNAME

# # Set the default command
# CMD /bin/bash


FROM openj9

USER root

# Define build arguments
ARG UNAME=testuser
ARG UID=1000
ARG GID=1000
ARG JENKINS_UID=1001
ARG JENKINS_GID=1001

# Change jenkins' UID and GID before creating 'uname' user
RUN usermod -u $JENKINS_UID jenkins && groupmod -g $JENKINS_GID jenkins
# Create a group with the specified GID
RUN groupadd -g $GID -o $UNAME

# Create a user with the specified UID and GID
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

# Install dependencies
RUN apt-get update && \
    apt-get install -y sudo nano git

# Ensure /home/jenkins exists and is owned by uid
RUN mkdir -p /home/jenkins && \
    chown -R $UID:$GID /home/jenkins

# # Make artifact directory
RUN mkdir -p /home/$UNAME/CS744 && \
    chown -R $UID:$GID /home/$UNAME/CS744

# Set the working directory
WORKDIR /home/$UNAME/CS744

# Switch to the new user
USER $UNAME

# Set the default command
CMD /bin/bash