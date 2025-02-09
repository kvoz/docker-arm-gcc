FROM ubuntu:22.04

# Download Linux support tools
RUN apt-get update && \
    apt-get clean && \ 
    apt-get install -y \
    sudo \
    build-essential \
    wget \
    cmake \
    git

# Using toolchain version
ARG ARM_TOOLCHAIN_VERSION="10.3-2021.10"
ARG ARM_TOOLCHAIN_DIR="/opt/gcc-arm-none-eabi"

# Download toolchain from official site
# Extract all files to ARM_TOOLCHAIN_DIR
RUN mkdir ${ARM_TOOLCHAIN_DIR} && \
    wget -qO- https://developer.arm.com/-/media/Files/downloads/gnu-rm/${ARM_TOOLCHAIN_VERSION}/gcc-arm-none-eabi-${ARM_TOOLCHAIN_VERSION}-x86_64-linux.tar.bz2 | tar -xvj -C ${ARM_TOOLCHAIN_DIR} --strip-components=1

# Append binary folder to PATH env
ENV PATH $PATH:${ARM_TOOLCHAIN_DIR}/bin

# Create the user
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Configurate user (add to sudoers, add to plugdev group)
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && usermod -a -G plugdev $USERNAME

# Switch to new user (not root)
USER $USERNAME