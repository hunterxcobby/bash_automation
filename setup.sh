#!/usr/bin/env bash

echo "Hey Babe, \
Grant me the permission?:)*"

while true; do
    sleep 0.5
    echo "Waiting for your sudo password..."
    sudo apt-get install -y toilet && break
done

 # Display in a different font and colors
toilet -f bigmono9 -F gay "Happy Birthday!"
