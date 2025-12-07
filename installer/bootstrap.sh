#!/usr/bin/env bash

# This gets launched after the entire system is installed
# The script is executed as root, so you DO NOT need to prepend each command with `sudo`

add-apt-repository ppa:neovim-ppa/unstable -y
apt-get update
apt-get install neovim -y
