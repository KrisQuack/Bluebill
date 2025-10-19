#!/bin/bash

# This script is set to exit immediately if a command exits with a non-zero status.
set -ouex pipefail

### Install Repositories and Core Packages

# Add RPM Fusion (free and non-free) and Terra repositories.
# The '-y' flag assumes "yes" to any prompts, making the process non-interactive.
dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf5 install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release

### Install Multimedia and Codec Packages

# Install multimedia groups and swap ffmpeg-free for the full version.
dnf5 group install -y multimedia
dnf5 swap -y 'ffmpeg-free' 'ffmpeg' --allowerasing
dnf5 upgrade -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
dnf5 group install -y sound-and-video

### Install Hardware Acceleration and Additional Packages

# Install libraries for hardware-accelerated video decoding/encoding.
dnf5 install -y ffmpeg-libs libva libva-utils
dnf5 swap -y libva-intel-media-driver intel-media-driver --allowerasing
dnf5 install -y libva-intel-driver

# Install H.264 codec support.
dnf5 install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264
# ERRORS dnf5 config-manager -y setopt fedora-cisco-openh264.enabled=1
# + dnf5 config-manager -y setopt fedora-cisco-openh264.enabled=1
# Unknown argument "config-manager" for command "dnf5". Add "--help" for more information about the arguments.
# It could be a command provided by a plugin, try: dnf5 install 'dnf5-command(config-manager)'?

# Install a selection of tools and codecs.
dnf5 install -y \
    tmux \
    intel-media-driver \
    libavcodec-freeworld \
    distrobox \
    ffmpegthumbnailer \
    gnome-tweak-tool \
    heif-pixbuf-loader \
    libheif-freeworld \
    libheif-tools \
    pipewire-codec-aptx

dnf5 remove -y firefox firefox-langpacks

# COPR repositories can be enabled for specific package installations and
# then disabled to prevent them from being included in the final image.
# Example (commented out):
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# dnf5 -y copr disable ublue-os/staging

### Enable System Services

# Enable the Podman socket for running containers.
# This command is non-interactive by default.
systemctl enable podman.socket
systemctl disable NetworkManager-wait-online.service