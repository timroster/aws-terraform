#!/bin/bash

sudo apt-get update
sudo apt-get install -y squid

# touch done file in ubuntu's home dir
touch ~ubuntu/cloudinit.done