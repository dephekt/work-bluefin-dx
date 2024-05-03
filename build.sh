#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

# import gpg keys
find /tmp/keys -type f -print0 | xargs -0 -I {} rpm --import {}

# get any rpm installers we need
curl -L -o /tmp/protonvpn-repo.rpm https://repo.protonvpn.com/fedora-${RELEASE}-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.1-2.noarch.rpm
curl -L -o /tmp/veracrypt.rpm https://launchpad.net/veracrypt/trunk/1.26.7/+download/veracrypt-1.26.7-CentOS-8-x86_64.rpm

# install our rpm packages
rpm-ostree install /tmp/protonvpn-repo.rpm /tmp/veracrypt.rpm

# install protonvpn app indicator support
rpm-ostree install --idempotent proton-vpn-gnome-desktop libappindicator-gtk3 gnome-shell-extension-appindicator gnome-extensions-app
