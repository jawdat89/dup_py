#!/bin/bash

dir="$(readlink -m $(dirname "$0"))"
cd $dir/../src

VERSION=`cat ./version.txt`
VERSION=${VERSION:1:10}
echo VERSION=$VERSION

outdir=../build-pyinstaller$venvname

rm -rf $outdir
mkdir $outdir

echo ''
echo running-pyinstaller
echo wd:`pwd`

echo `python3 --version` > distro.info.txt
echo ""  >> distro.info.txt
echo "pyinstaller " `pyinstaller --version` >> distro.info.txt

echo ''
echo running-pyinstaller-stage_dup_py
pyinstaller --noconfirm --noconsole --clean --optimize 2 --noupx \
    --add-data="distro.info.txt:." --add-data="version.txt:." --add-data="../LICENSE:." \
    --contents-directory=internal --distpath=$outdir --name dup_py --additional-hooks-dir=. \
    --collect-binaries tkinterdnd2 \
    --hidden-import='PIL._tkinter_finder' \
    --hidden-import="sklearn.cluster._dbscan_inner_" \
    ./dup_py.py

echo ''
echo packing
cd $outdir
zip -9 -r -m ./dup_py.lin.zip ./dup_py
