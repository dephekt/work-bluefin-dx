#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

# import custom justfile into 60-custom.just
cat /tmp/just/60-custom.just >> /usr/share/ublue-os/just/60-custom.just

# import gpg keys
find /tmp/keys -type f -print0 | xargs -0 -I {} rpm --import {}

# get any rpm installers we need
curl -L -o /tmp/protonvpn-repo.rpm https://repo.protonvpn.com/fedora-${RELEASE}-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.1-2.noarch.rpm
curl -L -o /tmp/veracrypt.rpm https://launchpad.net/veracrypt/trunk/1.26.7/+download/veracrypt-1.26.7-CentOS-8-x86_64.rpm

# install our rpm packages
rpm-ostree install /tmp/protonvpn-repo.rpm /tmp/veracrypt.rpm

# install protonvpn app indicator support
rpm-ostree install --idempotent \
    proton-vpn-gnome-desktop \
    libappindicator-gtk3 \
    gnome-shell-extension-appindicator \
    gnome-extensions-app

# pyenv: install python build dependencies
# `patch` is needed to build python 2.7.18, it pulls in `ed` also
rpm-ostree install --idempotent \
    bzip2-devel \
    libffi-devel \
    lzma-sdk-devel \
    ncurses-devel \
    openssl-devel \
    patch \
    readline-devel \
    sqlite-devel \
    tk-devel \
    zlib-devel

# platform desktop host dependencies
#   testbed poetry build requirements
#   git-annex is required for managing the release archive

#   note: runtime testbed dependencies are installed in a pet (distrobox) container,
#   these are just for setting up the local poetry environment for testbed which gets
#   mounted into the testbed pet container
rpm-ostree install --idempotent \
    git-annex \
    lzo-devel \
    python3-devel \
    systemd-devel
