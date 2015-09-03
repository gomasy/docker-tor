#!/bin/sh

sudo -u tor tor &
su -l gomasy -c "DISPLAY=:0 chromium --proxy-server=\"socks5://localhost:9050\" https://check.torproject.org/"
