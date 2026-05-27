#!/bin/bash

dir="$(readlink -m $(dirname "$0"))"
cd $dir/../src

echo writing version
python3 version.py

echo writing distro.info.txt
python3 --version > distro.info.txt
echo >> distro.info.txt
echo "development build" >> distro.info.txt
